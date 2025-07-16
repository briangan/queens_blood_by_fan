class DecksController < InheritedResources::Base

  before_action :authorize_user, only: [:show]

  def index
    Deck.populate_decks_for_user(current_user)
    @decks = Deck.includes(:cards).where(user_id: current_user.id).all
    if @decks.present?
      redirect_to @decks.first
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
