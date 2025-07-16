module DecksHelper
  def user_decks
    @decks ||= Deck.includes(:cards).where(user_id: current_user.id).all
  end
end