class Game < ActiveRecord::Base
  has_many :game_users, class_name:'GameUser', dependent: :destroy
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
      create_game_board_tiles
    end
    raise ArgumentError.new('Game must have game_board_tiles') if game_board_tiles.blank?

    users = self.users.order(:move_order).all

    # Copy the board tiles to the game board tiles.
    board.board_tiles.each do |bto|
      gbt = self.find_tile(bto.column, bto.row)
      gbt ||= game_board_tiles.create(column: bto.column, row: bto.row)
      gbt.update(pawn_value: gbt.pawn_value || 1, claiming_user_id: users[bto.claiming_user_number - 1].id, claimed_at: Time.now) if gbt.claiming_user_id.nil?
    end
  end

  # @game_move [GameMove]
  def proceed_with_game_move(game_move)
  end

  # Either start 1st turn for nil @current_turn_user_id or switch to next player.
  # @return [Integer] current_turn_user_id
  def go_to_next_turn!
    # Next turn
    if current_turn_user_id.nil?
      # If no current turn user, set to player 1.
      self.current_turn_user_id = game_users.first.user_id
    else
      # Otherwise, switch to the next player.
      next_player = game_users.where("user_id NOT IN (?)", current_turn_user_id).first
      self.update(current_turn_user_id: next_player.user_id) if next_player
    end
    self.current_turn_user_id
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
  # @return <Hash of column => Array of <BoardTile>>
  def game_board_tiles_map
    unless @game_board_tiles_map
      @game_board_tiles_map = game_board_tiles.order(:column, :row).to_a.group_by(&:column)
    end
    @game_board_tiles_map
  end


  # pick_pawns_for_players! is now done within @copy_from_board_to_game_board_tiles!
  
  # Ordered list of User in the game by move_order.
  def players
    @players = game_users.includes(:user).order(:move_order).map(&:user)
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
