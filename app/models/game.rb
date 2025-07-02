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

  def pick_pawns_for_players!
    raise 'Game must have 2 players' if users.size < 2
    board.pick_pawns_for_players!(users)
  end
end
