class Game < ActiveRecord::Base
  has_many :games_users
  has_many :users, through: :games_users
  has_many :games_cards
  has_many :cards, through: :games_cards
  has_one :board
  has_many :game_moves
end
