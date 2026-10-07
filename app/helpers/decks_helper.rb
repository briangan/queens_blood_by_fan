module DecksHelper
  def user_decks
    @decks ||= Deck.includes(:cards).where(user_id: current_user.id).all
  end

  # Iterates through the user's decks and subtracts quantities of cards that are already in the deck.
  def user_cards_after_deck_changes(user_cards, deck)
    # Returns the user cards that are not in the specified deck
    card_id_to_qty = {}
    deck.deck_cards.each do |deck_card|
      qty = card_id_to_qty[deck_card.card_id] || 0
      card_id_to_qty[deck_card.card_id] = qty + 1
    end
    user_cards.each do |user_card|
      if card_id_to_qty[user_card.card_id].to_i > 0
        user_card.quantity -= card_id_to_qty[user_card.card_id]
        user_card.quantity = 0 if user_card.quantity < 0
      end
    end
    user_cards
  end
end