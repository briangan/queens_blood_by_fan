class GamesController < ::InheritedResources::Base
  def index
    @games = Game.includes(:board).page(params[:page])
    set_page_title_suffix(@games)
    
  end
end