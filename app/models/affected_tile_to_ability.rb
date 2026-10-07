##
# The association between CardAbility and targeted tile on the game board that has card abilities affecting it by other tile(s).
# Originally called GameBoardTileAbility.
#
class AffectedTileToAbility < ApplicationRecord
  self.table_name = 'game_board_tiles_abilities'
  
  belongs_to :game_board_tile
  belongs_to :card_ability

  validates :game_board_tile_id, presence: true
  validates :card_ability_id, presence: true

  # Additional validations or methods can be added here as needed.
end