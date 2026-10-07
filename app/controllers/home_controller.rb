class HomeController < ApplicationController
  def index
    @games = Game.includes(:board).page(params[:page])
  end

  def access_denied
    logger.debug "| flash: #{flash}"
    flash.now[:alert] = 'You do not have permission to access this page.'
    render 'home/access_denied', status: :forbidden
  end

  def readme
    markdown = File.read('/Users/brian/Downloads/dev/macrufus/README.md')
    renderer = Redcarpet::Render::HTML.new
    @content = Redcarpet::Markdown.new(renderer).render(markdown).html_safe
    # render @content as HTML in the view
    render 'home/readme'
  end
end