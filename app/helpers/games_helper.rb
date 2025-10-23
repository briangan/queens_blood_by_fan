module GamesHelper
  # TODO: Pick best set cards for the player: deck w/ most cards, or random from all user cards
  # If game is in progress, subtract copies of cards already on the board
  def best_set_of_cards_for_player(player, game = nil)
    cards = player.cards.includes(:card_abilities, :card_tiles, :pawn_tiles, :affected_tiles).order('RANDOM()').limit(Deck::MAX_CARDS_PER_DECK).all.to_a
    if game.is_a?(Game) && game.in_progress?
      game.game_board_tiles.where(claiming_user_id: player.id).where('current_card_id IS NOT NULL').each do |tile|
        cards.delete(tile.current_card)
      end
    end
    cards
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

  def game_board_tile_cell_options(game_board_tile, the_game = nil, board_index = nil)
    the_game ||= game_board_tile.game
    {
      id: "game_board_tile_#{game_board_tile&.id}",
      class: "board-tile board-tile-#{board_tile_odd_or_even(game_board_tile, board_index)}#{' droppable' if game_board_tile.current_card_id.nil?}",
      data: game_board_tile.cell_data_attr.merge({ player: which_player_number_for_claiming_user(game_board_tile, the_game) })
    }
  end

  # @the_game <Game> for efficiency, to avoid another game_board_title.game call.
  def game_board_tile_cell_tag(game_board_tile, the_game = nil, board_index = nil)
    the_game ||= game_board_tile.game
    tag.td( **game_board_tile_cell_options(game_board_tile, the_game, board_index) ) do
      yield
    end
  end

  # @row_number <Integer> 1 to rows
  # @which_player_number <Integer> 1 or 2
  def row_player_score_label(game, row_number, which_player_number, player_1_score = nil, player_2_score = nil)
    total_scores = game.total_scores_for_all_rows[row_number] || {}
    player_1_score ||= total_scores.dig(row_number, game.player_1.id) || 0
    player_2_score ||= total_scores.dig(row_number, game.player_2.id) || 0
    has_higher_score = (which_player_number == 1 && player_1_score > player_2_score) || (which_player_number == 2 && player_2_score > player_1_score)
    tag.span((which_player_number == 2 ? player_2_score : player_1_score), class: "row-total-score#{'-dark' unless has_higher_score} row-total-score-player-1", 'data-bs-toggle'=>'tooltip',
      'data-bs-title'=>"Row #{row_number} total score for Player #{which_player_number}")
  end
end