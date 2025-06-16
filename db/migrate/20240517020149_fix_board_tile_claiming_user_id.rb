class FixBoardTileClaimingUserId < ActiveRecord::Migration[7.1]
  def up
    if column_exists?(:board_tiles, :claming_user_id)
      rename_column :board_tiles, :claming_user_id, :claiming_user_id
    end
    unless index_exists?(:board_tiles, [:board_id, :claiming_user_id])
      add_index :board_tiles, [:board_id, :claiming_user_id]
    end
  end

  def down
    if column_exists
      rename_column :board_tiles, :claiming_user_id, :claming_user_id
    end
  end
end
