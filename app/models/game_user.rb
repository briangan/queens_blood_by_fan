class GameUser < ApplicationRecord
  self.table_name = 'games_users'

  belongs_to :game
  belongs_to :user
end