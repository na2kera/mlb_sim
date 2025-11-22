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

ActiveRecord::Schema[8.0].define(version: 2025_11_22_005401) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "games", force: :cascade do |t|
    t.datetime "date"
    t.string "status"
    t.bigint "home_team_id", null: false
    t.bigint "visitor_team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "game_pk"
    t.index ["game_pk"], name: "index_games_on_game_pk", unique: true
    t.index ["home_team_id"], name: "index_games_on_home_team_id"
    t.index ["visitor_team_id"], name: "index_games_on_visitor_team_id"
  end

  create_table "innings", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.integer "inning_number"
    t.integer "visitor_score"
    t.integer "home_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "half"
    t.integer "runs", default: 0
    t.integer "hits", default: 0
    t.integer "error_count", default: 0
    t.index ["game_id"], name: "index_innings_on_game_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.string "league"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "mlb_id"
    t.string "location_name"
    t.index ["mlb_id"], name: "index_teams_on_mlb_id", unique: true
  end

  add_foreign_key "games", "teams", column: "home_team_id"
  add_foreign_key "games", "teams", column: "visitor_team_id"
  add_foreign_key "innings", "games"
end
