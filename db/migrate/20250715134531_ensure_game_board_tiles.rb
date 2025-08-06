class EnsureGameBoardTiles < ActiveRecord::Migration[7.2]
  def up
    unless table_exists?(:game_board_tiles)
      create_table :game_board_tiles do|t|
        t.integer :game_id, null: false
        t.integer :board_id, null: false
        t.integer :column
        t.integer :row
        t.integer :pawn_value, default: 0
        t.integer :power_value, default: 0
        t.integer :current_card_id
        t.integer :claiming_user_id
        t.datetime :claimed_at
        t.index :game_id
        t.index :claiming_user_id
      end
    end
  end
end
