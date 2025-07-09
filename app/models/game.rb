class Game < ActiveRecord::Base
  has_many :game_users, class_name:'GameUser', dependent: :destroy
  has_many :users, through: :game_users
  belongs_to :winner, class_name: 'User', foreign_key: 'winner_user_id', optional: true

  has_many :games_cards, dependent: :destroy
  has_many :cards, through: :games_cards
  belongs_to :board, optional: true

  has_many :game_moves, dependent: :destroy
  has_many :game_board_tiles, dependent: :destroy

  delegate :columns, :rows, to: :board

  validates_presence_of :board

  # after_create :create_board_game_tiles! # handled by :check_board_changes
  # after_create :copy_from_board_to_game_board_tiles! # handled by :check_board_changes
  
  after_save :check_board_changes

  def create_board_game_tiles!
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
    raise ArgumentError.new('Game must have users') if users.empty?
    if game_board_tiles.blank?
      create_board_game_tiles!
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


  def pick_pawns_for_players!
    raise 'Game must have 2 players' if users.size < 2
    board.pick_pawns_for_players!(users)
  end

  private
  
  # If board has changed, need to reset the game board tiles.
  def check_board_changes
    if board_id_changed? && board_id.present?
      board_game_tiles.delete_all
      create_board_game_tiles!

      # If the board has changed, we need to copy the board tiles to the game board tiles.
      copy_from_board_to_game_board_tiles!
    end
  end
end
