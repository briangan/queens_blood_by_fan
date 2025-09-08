class DecksController < InheritedResources::Base

  before_action :authorize_user, only: [:show]

  def index
    Deck.populate_decks_for_user(current_user)
    @decks = Deck.includes(:cards).where(user_id: current_user.id).all
    if @decks.present?
      redirect_to @decks.first
    end
  end

  def update
    super do|format|
      format.js { render js:'', status: :ok }
      format.json { render json: resource.as_json, status: :ok }
    end
  end

  def select_deck_cards
    @deck = resource
    params.permit!
    if params[:card_ids].present?
      @deck.deck_cards.destroy_all
      # batch insert
      DeckCard.insert_all(params[:card_ids].reject(&:blank?).map { |card_id| { deck_id: @deck.id, card_id: card_id.to_i } })
      flash[:notice] = 'Deck cards updated successfully.'
    else
      flash[:alert] = 'No cards selected.'
    end
  end

  private

    def deck_params
      params.require(:deck).permit(:name)
    end

    # Check ownership of the resource
    def authorize_user
      if resource && resource.user_id != current_user.id
        flash[:alert] = 'You are not authorized to perform this action.'
        redirect_to decks_path
      end
    end

end
