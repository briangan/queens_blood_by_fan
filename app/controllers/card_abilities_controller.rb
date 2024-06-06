class CardAbilitiesController < InheritedResources::Base
  before_action :set_card, only: [:create]

  def create
    if @card && card_ability_permitted_params[:card_ability]
      @card.card_abilities.delete_all
      @card.update_card_ability(card_ability_permitted_params[:card_ability])
    end
    
    respond_to do |format|
      format.js
    end
  end

  private

  def set_card
    @card = Card.find_by_id(params[:card_id] || card_ability_permitted_params[:card_ability][:card_id])
    flash[:warning] = 'Card not found' if @card.nil?
  end

  def card_ability_permitted_params
    params.permit(card_ability: [:card_id, :type, :when, :which, :action, :action_type, :action_value])
  end
end