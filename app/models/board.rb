##
# Generic Board model to store the board data.
class Board < ApplicationRecord
  has_many :board_tiles, dependent: :destroy
end