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
  

  ##
  # Find the range of rows in the middle of the board.
  # @how_many_rows [Integer] number of rows
  def range_to_pick(how_many_rows = nil)
    how_many_rows ||= rows
    if how_many_rows <= 4
      1..how_many_rows
    else
      # Pick middle 3 rows if odd number of rows; else pick middle 2 rows.
      if (how_many_rows % 2 == 0)
        half_point = how_many_rows / 2
        half_point..(half_point + 1)
      else
        half_point = how_many_rows / 2
        half_point..(half_point + 2)
      end
    end
  end
end