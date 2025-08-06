class GameCard < ApplicationRecord
  belongs_to :game, optional: true, dependent: :destroy
  belongs_to :card, optional: true
  belongs_to :user_id, optional: true

  validates_presence_of :game_id, :card_id, :user_id
end