class GameCard < ApplicationRecord
  belongs_to :game, optional: true, dependent: :destroy
  belongs_to :card, optional: true

  validates_presence_of :game_id, :card_id
end