class CreateGameBoardTilesAbilities < ActiveRecord::Migration[7.2]
  def up
    create_table_unless_exists :game_board_tiles_abilities do |t|
      t.integer :source_game_board_tile_id, null: false
      t.integer :game_board_tile_id, null: false
      t.integer :card_ability_id, null: false
      t.integer :power_value_change, null: false, default: 0
      t.integer :pawn_value_change, null: false, default: 0

      t.index :source_game_board_tile_id
      t.index :game_board_tile_id
      t.index [:game_board_tile_id, :power_value_change]
      t.index [:game_board_tile_id, :pawn_value_change]
    end
  end

  def down
    drop_table_if_exists :game_board_tiles_abilities
  end
end
