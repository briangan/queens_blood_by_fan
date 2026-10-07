class AddTypeToGameMoves < ActiveRecord::Migration[7.2]
  def up
    add_column_unless_exists :game_moves, :type, :string, limit: 36, null: false, default: 'GameMove'
    add_index_unless_exists :game_moves, :type
  end

  def down
    remove_index_if_exists :game_moves, :type
    remove_column_if_exists :game_moves, :type
  end
end
