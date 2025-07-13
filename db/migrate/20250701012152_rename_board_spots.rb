class RenameBoardSpots < ActiveRecord::Migration[7.2]
  def up
    if table_exists?(:game_board_tiles)
      rename_table :board_spots, :game_board_tiles
    end
    if table_exists?(:game_board_tiles)
      add_column_unless_exists :game_board_tiles, :game_id, :integer, null: false, index: true
      # Rename :board_spot_id column of :game_moves to :game_board_tile_id
      rename_column :game_moves, :board_spot_id, :game_board_tile_id
    end

    drop_table_if_exists :board_spots_cards
    drop_table_if_exists :game_session_moves
  end

  def down
    if table_exists?(:game_board_tiles)
      rename_table :game_board_tiles, :board_spots
    end
    if table_exists?(:board_spots)
      remove_column_if_exists :board_spots, :game_id
    end
    # Rename :game_board_tile_id column of :game_moves back to :board_spot_id
    rename_column :game_moves, :game_board_tile_id, :board_spot_id
  end
end
