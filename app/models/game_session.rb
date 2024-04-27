class GameSession < ActiveRecord::Base
  has_many :users
  has_one :board
  has_many :game_session_moves
end

# Path: app/models/game_session_move.rb
class GameSession