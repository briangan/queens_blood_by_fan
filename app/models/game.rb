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

  after_create :create_board_game_tiles!
  

  def create_board_game_tiles!
    1.upto(columns) do |x|
      1.upto(rows) do |y|
        btile = self.game_board_tiles.where(column: x, row: y).first
        btile ||= self.game_board_tiles.create(column: x, row: y)
      end
    end
  end

  ##
  # @x [Integer] 1 to colunms
  # @y [Integer] 1 to rows
  # @return [BoardTile] or nil
  def find_tile(x, y)
    game_board_tiles_map[x].try(:[], y - 1)
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
end
