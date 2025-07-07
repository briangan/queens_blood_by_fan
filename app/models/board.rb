##
# Generic Board model to store the board data.
class Board < ApplicationRecord

  DEFAULT_BOARD_COLUMNS = 5
  DEFAULT_BOARD_ROWS = 3

  has_paper_trail on: [:update]

  has_many :board_tiles, dependent: :destroy

  def self.create_board(cols = DEFAULT_BOARD_COLUMNS, rows = DEFAULT_BOARD_ROWS)
    board = Board.where(columns: cols, rows: rows).last || Board.create(columns: cols, rows: rows)

    board.create_board_tiles!
    board
  end

  

  ##
  # Pick left-most column and middle 3 rows for player 1.
  # Pick right-most column and middle 3 rows for player 2.
  def pick_pawns_for_players!(players = nil)
    player1 = players[0]
    player2 = players[1]

    pick = range_to_pick(rows)
    player1_tiles = board_tiles.where(column: 1).where(row: pick )
    player2_tiles = board_tiles.where(column: columns).where(row: pick )

    player1_tiles.each do |tile|
      tile.attributes = { pawn_rank: 1, claiming_user_id: player1.id }
      tile.save
    end

    player2_tiles.each do |tile|
      tile.attributes = { pawn_rank: 1, claiming_user_id: player2.id }
      tile.save
    end
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