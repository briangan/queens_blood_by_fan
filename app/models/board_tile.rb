##
# The tile record on the board that holds the rules, such as which initially which player owns 
# the tile (@claiming_user_number should match GameUser#move_order), and the pawn value.
# Future considerations:
# * pawn_value higher than 1
class BoardTile < ApplicationRecord
  belongs_to :board

  validates_presence_of :column, :row, :board_id, :claiming_user_number

end