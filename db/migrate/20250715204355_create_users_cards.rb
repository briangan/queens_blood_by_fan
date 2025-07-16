class CreateUsersCards < ActiveRecord::Migration[7.2]
  def up
    create_table_unless_exists :users_cards do |t|
      t.integer :user_id, null: false
      t.integer :card_id, null: false
      t.integer :quantity, default: 1
      t.index :user_id
      t.index :card_id
    end
  end

  def down
    drop_table_if_exists :users_cards
  end
end
