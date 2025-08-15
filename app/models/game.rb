class Game < ActiveRecord::Base
  VALID_STATUSES = %w[WAITING IN_PROGRESS COMPLETED CANCELLED].freeze

  has_many :game_users, -> { order(:move_order) }, class_name:'GameUser', dependent: :destroy
  has_many :users, through: :game_users
  belongs_to :winner, class_name: 'User', foreign_key: 'winner_user_id', optional: true
  belongs_to :current_turn_user, class_name: 'User', foreign_key: 'current_turn_user_id', optional: true

  has_many :games_cards, dependent: :destroy
  has_many :cards, through: :games_cards
  belongs_to :board, optional: true

  has_many :game_moves, dependent: :destroy
  has_many :game_board_tiles, dependent: :destroy
  has_many :game_board_tiles_with_cards, -> { where("current_card_id IS NOT NULL") }, class_name: 'GameBoardTile'

  scope :waiting, -> { where(status: 'WAITING') }
  scope :incomplete, -> { where(status: ['WAITING', 'IN_PROGRESS'] ) }

  delegate :columns, :rows, to: :board

  validates_presence_of :board

  # after_create :create_game_board_tiles # handled by :check_board_changes
  # after_create :copy_from_board_to_game_board_tiles! # handled by :check_board_changes
  
  before_save :normalize_attributes
  after_create :initialize_board_changes
  after_save :check_board_changes

  VALID_STATUSES.each do |status|
    unless respond_to?("#{status.downcase}?")
      define_method("#{status.downcase}?") do
        self.status&.upcase == status
      end
    end
  end

  def current_turn_player_number
    return 1 if current_turn_user_id == player_1&.id
    return 2 if current_turn_user_id == player_2&.id
    nil
  end

  def the_other_player_user_id(user_id)
    game_users.find{|gu| gu.user_id != user_id }&.user_id
  end

  def create_game_board_tiles!
    tiles = []
    1.upto(columns) do |x|
      1.upto(rows) do |y|
        tiles << self.game_board_tiles.find_or_create_by(column: x, row: y) do |gbt|
            gbt.board_id = board_id
          end
      end
    end
    tiles
  end

  ##
  # This requires board_tiles and users to be present.
  def copy_from_board_to_game_board_tiles!
    raise ArgumentError.new('Game must have a board') unless board

    if game_board_tiles.blank?
      create_game_board_tiles!
    end
    raise ArgumentError.new('Game must have game_board_tiles') if game_board_tiles.blank?

    users = self.users.all

    # Copy the board tiles to the game board tiles.
    board.board_tiles.each do |bto|
      gbt = self.find_tile(bto.column, bto.row)
      gbt ||= game_board_tiles.create(column: bto.column, row: bto.row)
      gbt.update(pawn_value: gbt.pawn_value || 1, claiming_user_id: users[bto.claiming_user_number - 1]&.id, claimed_at: Time.now) if gbt.claiming_user_id.nil?
    end
  end

  # @game_move <GameMove> expected valid.
  # @options <Hash> additional
  #   :dry_run [Boolean] if true, do not save the game_move, just return affected tiles.
  # @return <Array of GameBoardTile> affected tiles.
  def proceed_with_game_move(game_move, options = {})
    dry_run = options[:dry_run] || false
    changed_tiles = []
    player_number = game_move.user_id == player_2.id ? 2 : 1
    x_sign = player_number == 2 ? -1 : 1
    self.class.logger.info "| proceed_with_game_move (dry_run? #{dry_run}), valid? #{game_move.valid?}:\n#{game_move.attributes.as_json }"
    # Check if the move is valid (which internally checks user turn and tile and card).
    if game_move.valid?
      # Proceed with the move.
      game_move.save unless dry_run

      game_move.game_board_tile.attributes = { current_card_id: game_move.card.id, claiming_user_id: game_move.user_id, claimed_at: Time.now, power_value: game_move.card.power }
      game_move.game_board_tile.current_card = game_move.card
      game_move.game_board_tile.save unless dry_run
      changed_tiles << game_move.game_board_tile
      self.class.logger.info "| game_board_tile: #{game_move.game_board_tile.attributes.as_json}"

      game_move.game_board_tile.apply_after_card_event(CardEvent.new(self, game_move.card, 'played', dry_run: dry_run)) do |card_tile, other_t|
        changed_tiles << other_t
      end
    
      game_move.game_board_tile.update(claiming_user_id: current_turn_user.id, claimed_at: Time.now) unless dry_run
      
      # Immediately update the game_board_tiles_map to include the new tile.  Mainly for debugging.
      self.game_board_tiles_map[game_move.game_board_tile.row] ||= []
      if (existing_same_tile = find_tile(game_move.game_board_tile.column, game_move.game_board_tile.row) ).nil?
        self.game_board_tiles_map[game_move.game_board_tile.row] << game_move.game_board_tile
        self.game_board_tiles_map[game_move.game_board_tile.row].sort!(&:column)
      end

      game_move.move_order = self.game_moves.where("id != ?", game_move.id).order(:move_order).last&.move_order.to_i + 1
      game_move.save unless dry_run

      if dry_run
        self.current_turn_user = (current_turn_user_id == player_2&.id) ? player_1 : player_2
        self.current_turn_user_id = self.current_turn_user&.id
      else
        go_to_next_turn!
      end
    end # if game_move.valid?
    changed_tiles
  end

  # Either start 1st turn for nil @current_turn_user_id or switch to next player.
  # @return [Integer] current_turn_user_id
  def go_to_next_turn!
    # Next turn
    if current_turn_user_id.nil? # supposedly random pick
      # If no current turn user, set to player 1.
      self.update(current_turn_user_id: game_users.first.user_id)
      self.game_users.where(user_id: current_turn_user_id).update_all(move_order: 1)
      self.game_users.where("user_id != ?", current_turn_user_id).update_all(move_order: 2)
    else
      # Otherwise, switch to the next player.
      next_player = game_users.where("user_id NOT IN (?)", current_turn_user_id).first
      self.update(current_turn_user_id: next_player.user_id) if next_player
    end
    self.current_turn_user_id
  end

  ##
  # Reset the game to initial state: unset current_turn_user_id, winner_user_id;
  # deletes game_moves; deletes & recreates game_board_tiles.
  def reset!
    self.update(current_turn_user_id: nil, winner_user_id: nil)
    self.game_moves.delete_all
    self.game_board_tiles.delete_all
    self.copy_from_board_to_game_board_tiles!
    self.go_to_next_turn! if self.current_turn_user_id.nil?
  end

  ##
  # @column [Integer] 1 to colunms
  # @row [Integer] 1 to rows
  # @return [GameBoardTile] or nil
  def find_tile(column, row)
    t = nil
    if (row_list = game_board_tiles_map[row] )
      t = row_list.find{|bt| bt.column == column } 
    end
    t
  end

  ##
  # Matrix array of board tiles.
  # @return <Hash of row => Array of <GameBoardTile w/ column> >
  def game_board_tiles_map
    unless @game_board_tiles_map
      @game_board_tiles_map = game_board_tiles.includes(:affecting_card_abilities, :current_card => [:card_abilities, :pawn_tiles, :affected_tiles]).order(:row, :column).to_a.group_by(&:row)
    end
    @game_board_tiles_map
  end

  # @return <Hash> with keys: :player_1, :player_2, $user_1_id, $user_2_id
  def total_scores_for_all_rows
    all_row_scores = {}
    row_scores_sample = { player_1: 0, player_2: 0, player_1.id => 0, player_2.id => 0 }

    game_board_tiles_map.each do |row, tiles|
      row_score = all_row_scores[row] || row_scores_sample.dup
      tiles.each do |t|
        next if t.current_card.nil? || t.claiming_user_id.nil?
        # logger.info " \\_ tile (#{t.id}) at [#{t.column},#{t.row}] card #{t.current_card&.card_number}, #{t.pawn_value} pawns, #{t.power_value} power: #{t.affected_tiles_to_abilities.includes(:card_ability).collect{|ga| "#{ga.card_ability.type} #{ga.power_value_change}" }.as_json }"
        
        p = t.power_value.to_i
        # player-specific scores
        if t.claiming_user_id == player_1.id
          row_score[:player_1] += p
          row_score[player_1.id] += p
        elsif t.claiming_user_id == player_2.id
          row_score[:player_2] += p
          row_score[player_2.id] += p
        end
      end
      all_row_scores[row] = row_score
    end
    all_row_scores
  end

  # pick_pawns_for_players! is now done within @copy_from_board_to_game_board_tiles!
  
  # Ordered list of User in the game by move_order.
  def players
    @players ||= game_users.includes(:user).map(&:user)
  end

  def player_1
    players.first
  end
  alias_method :user_1, :player_1
  alias_method :first_player, :player_1

  def player_2
    players[1]
  end
  alias_method :user_2, :player_2
  alias_method :second_player, :player_2

  def which_player_number(user_id)
    return 1 if player_1 && user_id == player_1&.id
    return 2 if player_2 && user_id == player_2&.id
    nil
  end

  # ASCII representation of the game board.  For console debugging.
  # Each file has 2 rows of text:
  #   " iii (30) " - pawn value and power value of the tile
  #   " [123] p1 " - card number and claiming user number (not user.id)
  def board_ascii_s(spaces_per_tile = 10)
    hborder = ('+' + '-' * spaces_per_tile ) * columns + '+'
    all_rows = [hborder] # the text of each row w/o endline
    board_map = game_board_tiles_map
    (1..rows).each do |row|
      row_s = ['', ''] # 2 rows for each game board row: 
      row_tiles = board_map[row] || []
      row_tiles.each do |tile|
        row_s[0] << '| ' + ('%3s (%2s) ' % ['i' * tile.pawn_value.to_i, tile.power_value.to_i] )
        row_s[1] << '| ' + ('[%3s] %2s ' % [tile.current_card&.card_number.to_s, 
          tile.claiming_player_number ? 'p' + tile.claiming_player_number.to_s : ''] )
      end
      all_rows << row_s[0] + '|'
      all_rows << row_s[1] + '|'
      all_rows << hborder
    end # each row
    all_rows.join("\n")
  end

  private

  def normalize_attributes
    self.status = 'WAITING' if self.status.blank? || VALID_STATUSES.exclude?(self.status&.upcase)
  end

  def initialize_board_changes
    check_board_changes(true)
  end
  
  # If board has changed, need to reset the game board tiles.
  def check_board_changes(force_to_reload = false)
    if (force_to_reload || board_id_changed? ) && board_id
      self.game_board_tiles.delete_all
      create_game_board_tiles!

      # If the board has changed, we need to copy the board tiles to the game board tiles.
      copy_from_board_to_game_board_tiles!
    end
  end
end
