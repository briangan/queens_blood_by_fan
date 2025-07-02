class GameUser < ApplicationRecord
  self.table_name = 'games_users'

  belongs_to :game, optional: true, dependent: :destroy
  belongs_to :user, optional: true
end