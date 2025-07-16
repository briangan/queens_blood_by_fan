class GamesController < ::InheritedResources::Base
  def index
    @games = Game.includes(:board).page(params[:page])
    set_page_title_suffix(@games)
    
  end

  def create_game_move
    @game ||= resource
    logger.info "Creating game move for game #{@game.id} by user #{current_user.id}"
    if @game.current_turn_user_id == current_user.id
      flash[:notice] = 'Game move created successfully.'

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @game }
      end
    else
      flash[:alert] = 'It is not your turn to make a move.'

      respond_to do |format|
        format.js { render 'shared/show_alert_modal' }
        format.html { redirect_to @game }
      end
    end
  end
end