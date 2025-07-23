module GamesHelper
  # TODO: Pick best set cards for the player: deck w/ most cards, or random from all user cards
  def best_set_of_cards_for_player(player)
    player.cards.includes(:card_abilities, :card_tiles, :pawn_tiles, :affected_tiles).order('RANDOM()').limit(Deck::MAX_CARDS_PER_DECK).all
  end

  # @tile <GameBoardTile>
  # @board_tile_index <Integer> index of the tile in the board, starting from 1.  If not provided, it will be calculated based on tile's row and column.
  def board_tile_odd_or_even(tile, board_tile_index = nil)
    board_tile_index ||= (tile.row - 1) * tile.board.columns + tile.column
    board_tile_index.even? ? 'even' : 'odd'
  end
end