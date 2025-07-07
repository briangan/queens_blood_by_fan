class AddClaimingToGameBoardTiles < ActiveRecord::Migration[7.2]
  def up
    add_column_unless_exists :game_board_tiles, :claiming_user_id, :integer, null: true
    add_column_unless_exists :game_board_tiles, :claimed_at, :integer, null: true

    add_index :game_board_tiles, :claiming_user_id unless index_exists?(:game_board_tiles, :claiming_user_id)

    drop_table_if_exists :board_tiles
    create_table :board_tiles do |t|
      t.integer :board_id, null: false
      t.integer :column, null: false
      t.integer :row, null: false
      t.integer :pawn_value, default: 1
      t.integer :claiming_user_number, null: false

      t.index :board_id
      t.index [:board_id, :claiming_user_number]
    end
  end

  def down
    remove_index :game_board_tiles, :claiming_user_id if index_exists?(:game_board_tiles, :claiming_user_id)

    remove_column_if_exists :game_board_tiles, :claiming_user_id
    remove_column_if_exists :game_board_tiles, :claimed_at

    drop_table_if_exists :board_tiles
  end
end
