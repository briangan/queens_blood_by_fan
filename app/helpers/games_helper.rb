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

  def which_player_number_for_current_user(game)
    if game.player_1&.id == current_user.id
      1
    elsif game.player_2&.id == current_user.id
      2
    else
      nil
    end
  end

  def which_player_number_for_claiming_user(game_board_tile, game = nil)
    game ||= game_board_tile.game
    return nil unless game_board_tile.claiming_user_id
    if game.player_1&.id == game_board_tile.claiming_user_id
      1
    elsif game.player_2&.id == game_board_tile.claiming_user_id
      2
    else
      nil
    end
  end

  # @the_game <Game> for efficiency, to avoid another game_board_title.game call.
  def gamble_board_tile_cell_tag(game_board_tile, the_game = nil, board_index = nil)
    the_game ||= game_board_tile.game
    content_tag :td, id: "game_boad_tile_#{game_board_tile&.id}", class: "board-tile board-tile-#{board_tile_odd_or_even(game_board_tile, board_index)} droppable", data: game_board_tile.cell_data_attr.merge({ player: which_player_number_for_claiming_user(game_board_tile, the_game) }) do
      yield 
    end
  end
end