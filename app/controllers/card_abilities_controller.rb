class CardAbilitiesController < InheritedResources::Base
  before_action :set_card, only: [:create]

  def create
    if @card && permitted_params[:card_ability]
      @card.card_abilities.delete_all
      @card.update_card_ability(permitted_params[:card_ability])
    end
    
    respond_to do |format|
      format.js
    end
  end

  def update
    super do |format|
      format.js
    end
  end

  private

  def set_card
    @card = Card.find_by_id(params[:card_id] || permitted_params[:card_ability][:card_id])
    flash[:warning] = 'Card not found' if @card.nil?
  end

  def permitted_params
    params.permit(card_ability: CardAbility::PERMITTED_PARAMS)
  end
end