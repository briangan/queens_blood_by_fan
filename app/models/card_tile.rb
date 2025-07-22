##
# The values of x & y start from top-left corner of the board.
# TODO: For affected tiles, there r 2 diff colors: 
class CardTile < ApplicationRecord
  belongs_to :card, optional: true
  TYPES = %w[CardTile::Pawn CardTile::Affected]
end