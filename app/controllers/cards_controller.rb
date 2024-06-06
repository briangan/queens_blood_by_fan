class CardsController < InheritedResources::Base
  helper CardAbilitiesHelper
  
  def index
    @cards = Card.includes(:card_tiles, :card_abilities).order(:card_number).page(params[:page])
    set_page_title_suffix(@cards, 'card')
    
    respond_to do |format|
      format.html
      format.json { render json: @cards }
    end
  end

  def update
    @card = Card.find(params[:id])
    if @card
      @card.update(card_permitted_params[:card])
      @card.update_card_tile_selections(params[:card_tiles])
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
    params.permit(card: [:type, :name, :category, :card_number, :description, :pawn_rank, :power, :raise_pawn_rank] )
  end
end