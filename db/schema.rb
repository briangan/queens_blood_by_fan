# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_04_27_015720) do
  create_table "board_spots", force: :cascade do |t|
    t.integer "board_id"
    t.integer "column"
    t.integer "row"
    t.integer "pawn_value", default: 0
    t.integer "powerup_value", default: 0
    t.integer "current_card_id"
    t.index ["board_id", "column", "row"], name: "index_board_spots_on_board_id_and_column_and_row"
    t.index ["board_id"], name: "index_board_spots_on_board_id"
  end

  create_table "board_spots_cards", force: :cascade do |t|
    t.integer "board_spot_id"
    t.integer "user_id"
    t.integer "card_id"
    t.integer "spot_order", default: 0
    t.index ["board_spot_id", "spot_order"], name: "index_board_spots_cards_on_board_spot_id_and_spot_order", unique: true
    t.index ["board_spot_id"], name: "index_board_spots_cards_on_board_spot_id"
  end

  create_table "boards", force: :cascade do |t|
    t.integer "columns", default: 5
    t.integer "rows", default: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cards", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.integer "card_number"
    t.text "description"
    t.integer "pawn_value", default: -1, null: false
    t.integer "powerup_value", default: 0
    t.index ["card_number"], name: "index_cards_on_card_number"
    t.index ["name"], name: "index_cards_on_name"
    t.index ["pawn_value"], name: "index_cards_on_pawn_value"
    t.index ["powerup_value"], name: "index_cards_on_powerup_value"
  end

  create_table "game_moves", force: :cascade do |t|
    t.integer "game_id"
    t.integer "user_id"
    t.integer "board_spot_id"
    t.integer "card_id"
    t.integer "move_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "move_order"], name: "index_game_moves_on_game_id_and_move_order"
    t.index ["game_id", "user_id"], name: "index_game_moves_on_game_id_and_user_id"
    t.index ["game_id"], name: "index_game_moves_on_game_id"
  end

  create_table "game_session_moves", force: :cascade do |t|
    t.integer "game_session_id"
    t.integer "user_id"
    t.integer "board_spot_id"
    t.integer "card_id"
    t.integer "move_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_session_id", "move_order"], name: "index_game_session_moves_on_game_session_id_and_move_order"
    t.index ["game_session_id", "user_id"], name: "index_game_session_moves_on_game_session_id_and_user_id"
    t.index ["game_session_id"], name: "index_game_session_moves_on_game_session_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "board_id"
    t.integer "winner_user_id"
    t.string "status", default: "0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_games_on_created_at"
  end

  create_table "games_cards", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "card_id", null: false
    t.integer "user_id"
    t.integer "deck_order", default: 0
    t.index ["game_id", "deck_order"], name: "index_games_cards_on_game_id_and_deck_order", unique: true
    t.index ["game_id", "user_id"], name: "index_games_cards_on_game_id_and_user_id"
    t.index ["game_id"], name: "index_games_cards_on_game_id"
  end

  create_table "games_users", force: :cascade do |t|
    t.integer "game_id"
    t.integer "user_id"
    t.integer "move_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "user_id"], name: "index_games_users_on_game_id_and_user_id"
    t.index ["game_id"], name: "index_games_users_on_game_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 100
    t.string "username", limit: 64, null: false
    t.integer "rank", default: 0
    t.float "rating", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
