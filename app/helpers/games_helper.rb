module GamesHelper
  # TODO: Pick best set cards for the player: deck w/ most cards, or random from all user cards
  def best_set_of_cards_for_player(player)
    player.cards.includes(:card_abilities, :card_tiles, :pawn_tiles, :affected_tiles).order('RANDOM()').limit(Deck::MAX_CARDS_PER_DECK).all
  end
end