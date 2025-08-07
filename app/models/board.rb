##
# Generic Board model to store the board data.
class Board < ApplicationRecord

  DEFAULT_BOARD_COLUMNS = 5
  DEFAULT_BOARD_ROWS = 3

  has_paper_trail on: [:update]

  has_many :board_tiles, dependent: :destroy

  def self.create_board(cols = DEFAULT_BOARD_COLUMNS, rows = DEFAULT_BOARD_ROWS)
    board = Board.where(columns: cols, rows: rows).last || Board.create(columns: cols, rows: rows)
    board.assign_claims_of_default_left_and_right_tiles!
    board
  end

  # Defaults of the user-claimed tiles: left 1st column of every row to player 1, right 1st column of every row to player 2.
  def assign_claims_of_default_left_and_right_tiles!
    list = []
    1.upto(rows) do |row|
      # Left tile for player 1
      bt1 = board_tiles.find_or_initialize_by(column: 1, row: row)
      bt1.claiming_user_number = 1
      bt1.pawn_value = 1
      bt1.save!
      list << bt1

      # Right tile for player 2
      bt2 = board_tiles.find_or_initialize_by(column: columns, row: row)
      bt2.claiming_user_number = 2
      bt2.pawn_value = 1
      bt2.save!
      list << bt2
    end
    list
  end

  # @return <Hash of [column, row] => Array of BoardTile >
  def board_tiles_map
    unless @board_tiles_map
      @board_tiles_map = board_tiles.all.group_by{|bto| [bto.column, bto.row] }
    end
    @board_tiles_map
  end
  
end