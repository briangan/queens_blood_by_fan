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

ActiveRecord::Schema[7.2].define(version: 2025_07_25_201605) do
  create_table "board_tiles", force: :cascade do |t|
    t.integer "board_id", null: false
    t.integer "column", null: false
    t.integer "row", null: false
    t.integer "pawn_value", default: 1
    t.integer "claiming_user_number", null: false
    t.index ["board_id", "claiming_user_number"], name: "index_board_tiles_on_board_id_and_claiming_user_number"
    t.index ["board_id"], name: "index_board_tiles_on_board_id"
  end

  create_table "board_tiles_cards", force: :cascade do |t|
    t.integer "board_tile_id"
    t.integer "user_id"
    t.integer "card_id"
    t.integer "spot_order", default: 0
    t.index ["board_tile_id", "spot_order"], name: "index_board_tiles_cards_on_board_tile_id_and_spot_order", unique: true
    t.index ["board_tile_id"], name: "index_board_tiles_cards_on_board_tile_id"
  end

  create_table "boards", force: :cascade do |t|
    t.integer "columns", default: 5
    t.integer "rows", default: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "card_abilities", force: :cascade do |t|
    t.integer "card_id", null: false
    t.string "type", limit: 32, null: false
    t.string "when", limit: 32
    t.string "which", limit: 64
    t.string "action_type", limit: 64
    t.string "action_value", limit: 64
    t.index ["card_id"], name: "index_card_abilities_on_card_id"
  end

  create_table "card_tiles", force: :cascade do |t|
    t.integer "card_id", null: false
    t.string "type", limit: 32, null: false
    t.integer "x", null: false
    t.integer "y", null: false
    t.index ["card_id", "x", "y"], name: "index_card_tiles_on_card_id_and_x_and_y"
    t.index ["card_id"], name: "index_card_tiles_on_card_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "type", limit: 32, default: "Card"
    t.string "name", limit: 64, null: false
    t.string "category", limit: 32, default: "Standard"
    t.integer "card_number"
    t.text "description"
    t.integer "pawn_rank", default: -1, null: false
    t.integer "power", default: 0
    t.integer "raise_pawn_rank", default: 1
    t.index ["card_number"], name: "index_cards_on_card_number"
    t.index ["name"], name: "index_cards_on_name"
    t.index ["pawn_rank"], name: "index_cards_on_pawn_rank"
    t.index ["power"], name: "index_cards_on_power"
  end

  create_table "decks", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", limit: 64
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_decks_on_user_id"
  end

  create_table "decks_cards", force: :cascade do |t|
    t.integer "deck_id", null: false
    t.integer "card_id", null: false
    t.integer "position", default: 0
    t.index ["card_id"], name: "index_decks_cards_on_card_id"
    t.index ["deck_id"], name: "index_decks_cards_on_deck_id"
  end

  create_table "game_board_tiles", force: :cascade do |t|
    t.integer "board_id"
    t.integer "column"
    t.integer "row"
    t.integer "pawn_value", default: 0
    t.integer "power_value", default: 0
    t.integer "current_card_id"
    t.integer "game_id", null: false
    t.integer "claiming_user_id"
    t.integer "claimed_at"
    t.index ["board_id", "column", "row"], name: "index_game_board_tiles_on_board_id_and_column_and_row"
    t.index ["board_id"], name: "index_game_board_tiles_on_board_id"
    t.index ["claiming_user_id"], name: "index_game_board_tiles_on_claiming_user_id"
    t.index ["game_id"], name: "index_game_board_tiles_on_game_id"
  end

  create_table "game_board_tiles_abilities", force: :cascade do |t|
    t.integer "source_game_board_tile_id", null: false
    t.integer "game_board_tile_id", null: false
    t.integer "card_ability_id", null: false
    t.integer "power_value_change", default: 0, null: false
    t.integer "pawn_value_change", default: 0, null: false
    t.index ["game_board_tile_id", "pawn_value_change"], name: "idx_on_game_board_tile_id_pawn_value_change_f54d35cf71"
    t.index ["game_board_tile_id", "power_value_change"], name: "idx_on_game_board_tile_id_power_value_change_b5c7c91557"
    t.index ["game_board_tile_id"], name: "index_game_board_tiles_abilities_on_game_board_tile_id"
    t.index ["source_game_board_tile_id"], name: "index_game_board_tiles_abilities_on_source_game_board_tile_id"
  end

  create_table "game_moves", force: :cascade do |t|
    t.integer "game_id"
    t.integer "user_id"
    t.integer "game_board_tile_id"
    t.integer "card_id"
    t.integer "move_order", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "move_order"], name: "index_game_moves_on_game_id_and_move_order"
    t.index ["game_id", "user_id"], name: "index_game_moves_on_game_id_and_user_id"
    t.index ["game_id"], name: "index_game_moves_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "board_id", null: false
    t.integer "winner_user_id"
    t.string "status", default: "0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_turn_user_id"
    t.index ["created_at"], name: "index_games_on_created_at"
  end

  create_table "games_cards", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "card_id", null: false
    t.integer "user_id"
    t.integer "deck_order", default: 0
    t.integer "usage_order"
    t.index ["game_id", "deck_order"], name: "index_games_cards_on_game_id_and_deck_order", unique: true
    t.index ["game_id", "usage_order"], name: "index_games_cards_on_game_id_and_usage_order"
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
    t.string "type", limit: 32, default: "User"
    t.string "email", limit: 100
    t.string "username", limit: 64, null: false
    t.string "password", limit: 127
    t.integer "rank", default: 0
    t.float "rating", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "users_cards", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "card_id", null: false
    t.integer "quantity", default: 1
    t.index ["card_id"], name: "index_users_cards_on_card_id"
    t.index ["user_id"], name: "index_users_cards_on_user_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 1073741823
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end
end
