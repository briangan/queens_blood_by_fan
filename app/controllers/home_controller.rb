class HomeController < ApplicationController
  def index
    @games = Game.includes(:board).page(params[:page])
  end

  def access_denied
    logger.debug "| flash: #{flash}"
    flash.now[:alert] = 'You do not have permission to access this page.'
    render 'home/access_denied', status: :forbidden
  end
end