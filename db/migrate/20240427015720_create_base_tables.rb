class CreateBaseTables < ActiveRecord::Migration[7.1]
  def up
    create_table_unless_exists :users do |t|
      t.string :type, limit: 32, default:'User'
      t.string :email, limit: 100
      t.string :username, limit: 64, null: false
      t.string :password, limit: 127
      t.integer :rank, default: 0
      t.float :rating, default: 0.0
      t.timestamps
      t.index :email, unique: true
      t.index :username, unique: true
    end

    create_table_unless_exists :boards do |t|
      t.integer :columns, default: 5
      t.integer :rows, default: 3
      t.timestamps
    end

    create_table_unless_exists :board_spots do |t|
      t.integer :board_id
      t.integer :column
      t.integer :row
      t.integer :pawn_value, default: 0
      t.integer :powerup_value, default: 0
      t.integer :current_card_id
      t.index :board_id
      t.index [:board_id, :column, :row]
    end

    create_table_unless_exists :board_spots_cards do |t|
      t.integer :board_spot_id
      t.integer :user_id
      t.integer :card_id
      t.integer :spot_order, default: 0
      t.index :board_spot_id
      t.index [:board_spot_id, :spot_order], unique: true
    end

    create_table_unless_exists :cards do |t|
      t.string :type, limit: 32, default:'Card'
      t.string :name, limit: 64, null: false
      t.integer :card_number
      t.text :description
      t.integer :pawn_value, default: -1, null: false
      t.integer :powerup_value, default: 0
      t.index :name
      t.index :card_number
      t.index :pawn_value
      t.index :powerup_value
    end



    create_table_unless_exists :games_cards do |t|
      t.integer :game_id, null: false
      t.integer :card_id, null: false
      t.integer :user_id
      t.integer :deck_order, default: 0
      t.index :game_id
      t.index [:game_id, :user_id]
      t.index [:game_id, :deck_order], unique: true
    end

    create_table_unless_exists :games do |t|
      t.integer :board_id
      t.integer :winner_user_id
      t.string :status, default: 0
      t.timestamps
      t.index :created_at
    end

    create_table_unless_exists :games_users do |t|  # join table
      t.integer :game_id
      t.integer :user_id
      t.integer :move_order, default: 0
      t.timestamps
      t.index :game_id
      t.index [:game_id, :user_id]
    end

    create_table_unless_exists :game_moves do |t|
      t.integer :game_id
      t.integer :user_id
      t.integer :board_spot_id
      t.integer :card_id
      t.integer :move_order, default: 0
      t.timestamps
      t.index :game_id
      t.index [:game_id, :user_id]
      t.index [:game_id, :move_order]
    end
  end

  def down
    drop_table_if_exists :users
    drop_table_if_exists :boards
    drop_table_if_exists :board_spots
    drop_table_if_exists :board_spots_cards
    drop_table_if_exists :cards
    drop_table_if_exists :games_cards
    drop_table_if_exists :games
    drop_table_if_exists :games_users
    drop_table_if_exists :games_moves
  end
end
