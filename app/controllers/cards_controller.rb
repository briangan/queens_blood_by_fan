class CardsController < InheritedResources::Base
  def index
    @cards = Card.includes(:card_tiles, :card_abilities).order(:card_number).page(params[:page])
    set_page_title_suffix(@cards)
    
    respond_to do |format|
      format.html
      format.json { render json: @cards }
    end
  end

  def update
    super do |format|
      format.js {  }
      format.json { render json: @card }
    end
  end

  def permitted_params
    params.permit! # (card: [:name, :category, :card_number, :description, :pawn_rank, :power, :raise_pawn_rank] )
  end
end