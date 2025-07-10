class AddCurrentTurnUserIdToGames < ActiveRecord::Migration[7.2]
  def up
    add_column_unless_exists :games, :current_turn_user_id, :integer, null: true, default: nil
  end

  def down
    remove_column_if_exists :games, :current_turn_user_id
  end
end
