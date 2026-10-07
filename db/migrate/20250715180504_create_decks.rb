class CreateDecks < ActiveRecord::Migration[7.2]
  def up
    create_table_unless_exists :decks do |t|
      t.integer :user_id, null: false
      t.string :name, limit: 64
      t.timestamps

      t.index :user_id
    end

    create_table_unless_exists :decks_cards do |t|
      t.integer :deck_id, null: false
      t.integer :card_id, null: false
      t.integer :position, default: 0

      t.index :deck_id
      t.index :card_id
    end

    add_column_unless_exists :games_cards, :usage_order, :integer
    add_index_unless_exists :games_cards, [:game_id, :usage_order]
  end

  def down
    drop_table_if_exists :decks_cards
    drop_table_if_exists :decks

    remove_index_if_exists :games_cards, column: [:game_id, :usage_order]
    remove_column_if_exists :games_cards, :usage_order
  end
end
