##
# Generic Board model to store the board data.
class Board < ApplicationRecord
  has_many :board_tiles, dependent: :destroy

  DEFAULT_BOARD_COLUMNS = 5
  DEFAULT_BOARD_ROWS = 3

  def self.create_board(cols = DEFAULT_BOARD_COLUMNS, rows = DEFAULT_BOARD_ROWS)
    board = Board.where(columns: cols, rows: rows).last || Board.create(columns: cols, rows: rows)

    1.upto(cols) do |x|
      1.upto(rows) do |y|
        btile = board.find_tile(x, y)
        btile ||= board.board_tiles.create(column: x, row: y)
      end
    end
    board
  end

  ##
  # @x [Integer] 1 to colunms
  # @y [Integer] 1 to rows
  def find_tile(x, y)
    board_tiles_matrix[x - 1].try(:[], y - 1)
  end

  ##
  # Matrix array of board tiles.
  # @return <Array of (Array of <BoardTile>) >
  def board_tiles_matrix
    @board_tiles_matrix ||= board_tiles.order(:column, :row).to_a
  end

  def assign_pawns!(users_to_tile_positions = nil)
    board_tiles.each do |tile|
      tile.update(pawn_rank: 0, total_power: 0, current_card_id: nil, claming_user_id: nil, claimed_at: nil)
    end
  end

  ##
  # Pick left-most column and middle 3 rows for player 1.
  # Pick right-most column and middle 3 rows for player 2.
  def pick_pawns_for_players!(players = nil)
    player1 = players[0]
    player2 = players[1]

    starting_row = board_tiles.collect(&:column).size <= 3 ? 1 : 2
    player1_tiles = board_tiles.where(column: 1).where(row: starting_row..(starting_row + 3) )
    player2_tiles = board_tiles.where(column: DEFAULT_BOARD_COLUMNS).where(row: starting_row..(starting_row + 3) )

    player1_tiles.each do |tile|
      tile.update(pawn_rank: 1, claming_user_id: player1.id)
    end

    player2_tiles.each do |tile|
      tile.update(pawn_rank: 1, claming_user_id: player2.id)
    end
  end
end