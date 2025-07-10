class GamesController < ::InheritedResources::Base
  def index
    @games = Game.includes(:board).page(params[:page])
    set_page_title_suffix(@games)
    
  end

  def create_game_move
    respond_to do |format|
      format.js { render js:'', status: :ok }
    end
  end
end