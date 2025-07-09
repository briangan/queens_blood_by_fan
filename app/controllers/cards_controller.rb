class CardsController < InheritedResources::Base
  helper CardAbilitiesHelper
  
  def index
    @cards = Card.includes(:card_tiles, :card_abilities).order(:card_number).page(params[:page]).limit(params[:limit]&.to_i || 20)
    set_page_title_suffix(@cards, 'card')
    
    respond_to do |format|
      format.turbo_stream
      format.html
      format.json { render json: @cards }
    end
  end

  def show
    @card ||= resource
    @page_title_suffix = [@card.name, @card.card_number.present? ? '#' + @card.card_number.to_s : nil].
      find_all(&:present?).join(' ') if @card
    respond_to do |format|
      format.html
      format.json { render json: @card }
    end
  end

  def update
    @card = Card.find(params[:id])
    if @card
      @card.update(card_permitted_params[:card])
      @card.update_card_tile_selections(params[:card_tiles])
      @card.update_card_abilities(card_permitted_params[:card_abilities])
    end
    respond_to do |format|
      format.js {  }
      format.json { render json: @card }
    end
  end

  def permitted_params
    params.permit!
  end

  def card_permitted_params
    params.permit( :card_tiles, card_abilities: CardAbility::PERMITTED_PARAMS, card: [:type, :name, :category, :card_number, :description, :pawn_rank, :power, :raise_pawn_rank] )
  end
end