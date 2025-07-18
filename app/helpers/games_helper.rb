module GamesHelper
  # TODO: Pick best set cards for the player: deck w/ most cards, or random from all user cards
  def best_set_of_cards_for_player(player)
    player.cards.order('RANDOM()').limit(Deck::MAX_CARDS_PER_DECK).all
  end
end