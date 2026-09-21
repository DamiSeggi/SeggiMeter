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

ActiveRecord::Schema[8.1].define(version: 2026_09_21_081246) do
  create_table "activity_logs", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "lobbies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "locked_by_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["locked_by_id"], name: "index_lobbies_on_locked_by_id"
    t.index ["user_id"], name: "index_lobbies_on_user_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lobby_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "word", null: false
    t.index ["lobby_id"], name: "index_submissions_on_lobby_id"
    t.index ["user_id"], name: "index_submissions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "activity_logs", "users"
  add_foreign_key "lobbies", "users"
  add_foreign_key "lobbies", "users", column: "locked_by_id"
  add_foreign_key "submissions", "lobbies"
  add_foreign_key "submissions", "users"
end
