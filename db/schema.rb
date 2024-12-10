# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_12_09_153801) do

  create_table "characters", force: :cascade do |t|
    t.string "character_id"
    t.string "image_code"
    t.integer "x_coord", default: 10
    t.integer "y_coord", default: 10
    t.integer "shards"
    t.integer "world_id", null: false
    t.index ["character_id"], name: "index_characters_on_character_id", unique: true
    t.index ["world_id"], name: "index_characters_on_world_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "receiver_id"
    t.integer "world_id"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "squares", force: :cascade do |t|
    t.string "square_id"
    t.string "world_name"
    t.integer "world_id", null: false
    t.integer "x"
    t.integer "y"
    t.string "weather"
    t.boolean "treasure"
    t.string "game"
    t.string "monsters"
    t.string "state"
    t.string "terrain"
    t.string "code"
    t.text "pixel_art"
    t.index ["square_id"], name: "index_squares_on_square_id", unique: true
    t.index ["world_id"], name: "index_squares_on_world_id"
  end

  create_table "user_worlds", force: :cascade do |t|
    t.string "user_world_id"
    t.string "user_role"
    t.boolean "owner"
    t.integer "user_id", null: false
    t.integer "world_id", null: false
    t.index ["user_id"], name: "index_user_worlds_on_user_id"
    t.index ["user_world_id"], name: "index_user_worlds_on_user_world_id", unique: true
    t.index ["world_id"], name: "index_user_worlds_on_world_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "session_token"
    t.string "default_currency", default: "USD"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["session_token"], name: "index_users_on_session_token"
  end

  create_table "worlds", force: :cascade do |t|
    t.string "world_id"
    t.string "world_name"
    t.datetime "last_played"
    t.integer "progress"
    t.index ["world_id"], name: "index_worlds_on_world_id", unique: true
  end

  add_foreign_key "characters", "worlds"
  add_foreign_key "squares", "worlds", on_delete: :cascade
  add_foreign_key "user_worlds", "users"
  add_foreign_key "user_worlds", "worlds"
end
