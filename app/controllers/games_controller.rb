class GamesController < ::InheritedResources::Base

  before_action :authorize_player!, only: [:create_game_move, :reset]

  def index
    params.permit!
    @games = Game.includes(:board, :users).page(params[:page])
    @games = @games.where(status: params[:status].split(',')) if params[:status].present?
    set_page_title_suffix(@games)
    
  end

  def create
    p = params.require(:game).permit(:board_id)
    @game = Game.new(p)
    @game.game_users.build(user_id: current_user.id, move_order: 1)
    if @game.save
      flash[:notice] = 'Game created successfully.'
      redirect_to @game
    else
      flash.now[:alert] = @game.errors.full_messages.join(', ')
      render :new
    end
  end

  def join
    @game = resource
    if @game.game_users.where(user_id: current_user.id).count > 0
      flash[:alert] = 'You are already a player of this game.'
    elsif @game.game_users.count >= 2
      flash[:alert] = 'This game already has enough players joined.'
    else
      @game.game_users.create(user: current_user, move_order: @game.game_users.count + 1)
      @game.update(status: 'IN_PROGRESS') if @game.game_users.count >= 2
      @game.go_to_next_turn! if @game.current_turn_user_id.nil?
      flash[:notice] = 'You have joined the game successfully.'
    end

    respond_to do |format|
      format.html { redirect_to @game }
      format.turbo_stream
    end
  end

  def create_game_move
    p = params.permit(:id, :game_board_tile_id, :card_id)
    @game ||= resource
    @game_board_tile = p[:game_board_tile_id] ? @game.game_board_tiles.where(id: p[:game_board_tile_id]).first : nil

    @game_move = GameMove.new(game_id: @game.id, user_id: current_user.id, game_board_tile_id: @game_board_tile&.id, card_id: p[:card_id])
    if @game.current_turn_user_id == current_user.id && @game_move.valid?
      @game_move.save!
      @changed_tiles = @game.proceed_with_game_move(@game_move) # , dry_run: true)

      logger.info "| changed_tiles: #{@changed_tiles.collect(&:attributes).as_json }"

      flash[:notice] = 'Game move created successfully.'

      respond_to do |format|
        format.turbo_stream
        format.js { render template: 'games/broadcast_game_move' }
        format.html { redirect_to game_path(id: @game.id, t: Time.now.to_i) }
      end
    else
      @game_board_tile.current_card_id = nil if @game_board_tile
      @changed_tiles = [] # [@game_board_tile].compact
      # logger.info "| changd_tiles: #{@changed_tiles.collect(&:attributes).to_yaml }"
      flash[:warning] = @game_move.errors.full_messages.join(', ')
      flash[:warning] << "  It's not your turn to make this move." if @game.current_turn_user_id != current_user.id
      logger.warn "| create_game_move failed: #{flash[:warning]}"

      respond_to do |format|
        format.turbo_stream
        format.js # { render template: 'shared/show_alert_modal' }
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
      format.html { redirect_to game_path(id: @game, t: Time.now.to_i) }
    end
  end

  protected

  def authorize_player!
    unless resource.game_users.where(user_id: current_user.id).exists?
      flash[:alert] = 'You are not a player of this game.'
      respond_to do|format|
        format.js { render template: 'shared/show_alert_modal', status: :ok }
        format.html { redirect_to games_path }
      end
    end
  end
end