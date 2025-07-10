class BoardsController < InheritedResources::Base

  actions :index, :show, :new, :create, :edit, :update

  def new
    @board = Board.new(columns: permitted_params[:columns] || Board::DEFAULT_BOARD_COLUMNS, 
      rows: permitted_params[:rows] || Board::DEFAULT_BOARD_ROWS )
    super
  end

  def update
    @board ||= resource
    @board.board_tiles.delete_all
    if (board_tiles = params[:board_tiles]).present?
      board_tiles.each do |key, value|
        if value.to_i > 0
          col, row = key.scan(/\d+/).map(&:to_i)
          if col > 0 && row > 0
            @board.board_tiles.create!(claiming_user_number: value, column: col, row: row)
          end
        end
      end
    end
    super do|format|
      format.js { render js:'', status: :ok }
      format.html { redirect_to params[:return_url].present? ? params[:return_url] : edit_board_path(@board) }
    end
  end
  
  private

    # This need to provide the board and board_tile params
    # to the update method.
    def permitted_params
      p = params.permit(board: {}, board_tiles: {})
      logger.debug "Permitted params: #{p.to_h}"
      p
    end

end
