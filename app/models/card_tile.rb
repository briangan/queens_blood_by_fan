##
# TODO: For affected tiles, there r 2 diff colors: 
class CardTile < ApplicationRecord
  belongs_to :card, optional: true
  TYPES = %w[CardTile::Pawn CardTile::Affected]
end