class Game < ActiveRecord::Base
  has_many :game_users, -> { order(:move_order) }, class_name:'GameUser', dependent: :destroy
  has_many :users, through: :game_users
  belongs_to :winner, class_name: 'User', foreign_key: 'winner_user_id', optional: true
  belongs_to :current_turn_user, class_name: 'User', foreign_key: 'current_turn_user_id', optional: true

  has_many :games_cards, dependent: :destroy
  has_many :cards, through: :games_cards
  belongs_to :board, optional: true

  has_many :game_moves, dependent: :destroy
  has_many :game_board_tiles, dependent: :destroy

  delegate :columns, :rows, to: :board

  validates_presence_of :board

  # after_create :create_game_board_tiles # handled by :check_board_changes
  # after_create :copy_from_board_to_game_board_tiles! # handled by :check_board_changes
  
  after_create :initialize_board_changes
  after_save :check_board_changes

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
      gbt.update(pawn_value: gbt.pawn_value || 1, claiming_user_id: users[bto.claiming_user_number - 1].id, claimed_at: Time.now) if gbt.claiming_user_id.nil?
    end
  end

  # @game_move <GameMove> expected valid.
  # @options <Hash> additional
  #   :dry_run [Boolean] if true, do not save the game_move, just return affected tiles.
  # @return <Array of GameBoardTile> affected tiles.
  def proceed_with_game_move(game_move, options = {})
    dry_run = options[:dry_run] || false
    changed_tiles = []
    # Check if the move is valid (which internally checks user turn and tile and card).
    if game_move.valid?
      # Proceed with the move.
      game_move.save unless dry_run

      game_move.game_board_tile.update(current_card_id: game_move.card.id, claiming_user_id: game_move.user_id, claimed_at: Time.now, power_value: game_move.card.power) unless dry_run
      changed_tiles << game_move.game_board_tile

      game_move.card.card_tiles.each do |card_tile|
        next if card_tile.x.to_i < 1 && card_tile.y.to_i < 1
        other_t = self.find_tile(game_move.game_board_tile.column + card_tile.y, game_move.game_board_tile.row + card_tile.x)
        if other_t
          other_t.update(pawn_value: other_t.pawn_value + 1, claiming_user_id: game_move.user_id, claimed_at: Time.now) unless dry_run
          changed_tiles << other_t
        end
      end
      
      game_move.game_board_tile.update(pawn_value: game_move.card.pawn_rank, claiming_user_id: current_turn_user.id, claimed_at: Time.now) unless dry_run

      game_move.move_order = self.game_moves.where("id != ?", game_move.id).order(:move_order).last&.move_order.to_i + 1
      game_move.save unless dry_run

      go_to_next_turn! unless dry_run
    end
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
    if (col_list = game_board_tiles_map[column] )
      t = col_list.find{|bt| bt.row == row } 
    end
    t
  end

  ##
  # Matrix array of board tiles.
  # @return <Hash of column => Array of <GameBoardTile>>
  def game_board_tiles_map
    unless @game_board_tiles_map
      @game_board_tiles_map = game_board_tiles.includes(:current_card).order(:column, :row).to_a.group_by(&:column)
    end
    @game_board_tiles_map
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

  def player_2
    players[1]
  end
  alias_method :user_2, :player_2


  private

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
