class HomeController < ApplicationController
  def index
    @games = Game.includes(:board).page(params[:page])
  end
end