class Game < ActiveRecord::Base
  has_many :game_users, class_name:'GameUser'
  has_many :users, through: :game_users
  belongs_to :winner, class_name: 'User', foreign_key: 'winner_user_id', optional: true

  has_many :games_cards
  has_many :cards, through: :games_cards
  belongs_to :board

  has_many :game_moves
end
