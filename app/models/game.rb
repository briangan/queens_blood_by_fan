class Game < ActiveRecord::Base
  has_many :game_users, class_name:'GameUser'
  has_many :users, through: :game_users

  has_many :games_cards
  has_many :cards, through: :games_cards
  has_one :board
  has_many :game_moves
end
