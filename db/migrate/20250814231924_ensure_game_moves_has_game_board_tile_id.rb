class EnsureGameMovesHasGameBoardTileId < ActiveRecord::Migration[7.2]
  def change
    if column_exists?(:game_moves, :board_tile_id)
      rename_column :game_moves, :board_tile_id, :game_board_tile_id
    end
  end
end
