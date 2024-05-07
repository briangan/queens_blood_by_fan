class CardTile < ApplicationRecord
  belongs_to :card
  TYPES = %w[CardTile::Pawn CardTile::Affected]
end