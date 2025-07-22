class GamesController < ::InheritedResources::Base
  def index
    @games = Game.includes(:board).page(params[:page])
    set_page_title_suffix(@games)
    
  end

  def create_game_move
    p = params.permit(:id, :game_board_tile_id, :card_id)
    @game ||= resource
    @game_board_tile = p[:game_board_tile_id] ? @game.game_board_tiles.where(id: p[:game_board_tile_id]).first : nil

    @game_move = GameMove.new(game_id: @game.id, user_id: current_user.id, game_board_tile_id: @game_board_tile&.id, card_id: p[:card_id])
    logger.debug "| game_move valid? #{@game.valid?}:\n#{@game_move.attributes.to_yaml }"
    if @game.current_turn_user_id == current_user.id && @game_move.valid?
      
      # @game_move.save!
      
      @changed_tiles = @game.proceed_with_game_move(@game_move, dry_run: true) # TODO: remove dry_run: true

      logger.debug "| changed_tiles: #{@changed_tiles.collect(&:attributes).to_yaml }"

      flash[:notice] = 'Game move created successfully.'

      respond_to do |format|
        format.turbo_stream
        format.js { render js:'', status: :ok } 
        format.html { redirect_to game_path(id: @game.id, t: Time.now.to_i) }
      end
    else
      flash[:warning] = @game_move.errors.full_messages.join(', ')

      respond_to do |format|
        format.turbo_stream
        format.js { render template: 'shared/show_alert_modal' }
        format.html { redirect_to @game }
      end
    end
  end

  def reset
    @game = resource
    if @game.reset!
      flash[:notice] = 'Game has been reset successfully.'
    else
      flash[:alert] = 'Failed to reset the game.'
    end

    respond_to do |format|
      format.html { redirect_to @game }
    end
  end
end