##
# Record that represents a card to be used by a player with attributes like name, card_number, pawn_rank, and power.
# Associations include tiles and abilities.
class Card < ApplicationRecord
  has_many :card_ability, dependent: :destroy
  has_many :card_tiles, dependent: :destroy

  validate_presence_of :name

  TYPES = %w[Card ReplacementCard]
  CATEGORIES = %w[Standard Legendary]
end