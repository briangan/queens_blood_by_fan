##
# Data of a board spot which can be empty or placed with a card.
class BoardTile < ApplicationRecord
  belongs_to :board
  
end