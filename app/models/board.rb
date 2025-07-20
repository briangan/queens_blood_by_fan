##
# Generic Board model to store the board data.
class Board < ApplicationRecord

  DEFAULT_BOARD_COLUMNS = 5
  DEFAULT_BOARD_ROWS = 3

  has_paper_trail on: [:update]

  has_many :board_tiles, dependent: :destroy

  def self.create_board(cols = DEFAULT_BOARD_COLUMNS, rows = DEFAULT_BOARD_ROWS)
    board = Board.where(columns: cols, rows: rows).last || Board.create(columns: cols, rows: rows)

    board
  end

  # @return <Hash of [column, row] => Array of BoardTile >
  def board_tiles_map
    unless @board_tiles_map
      @board_tiles_map = board_tiles.all.group_by{|bto| [bto.column, bto.row] }
    end
    @board_tiles_map
  end
  
end