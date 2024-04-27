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

ActiveRecord::Schema[7.1].define(version: 0) do
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

end
