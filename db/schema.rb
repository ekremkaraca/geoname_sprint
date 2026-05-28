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

ActiveRecord::Schema[8.1].define(version: 2026_05_28_194623) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "cities", force: :cascade do |t|
    t.jsonb "aliases", default: [], null: false
    t.datetime "created_at", null: false
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.string "name", null: false
    t.string "normalized_name", null: false
    t.integer "population"
    t.bigint "quiz_id", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id", "normalized_name"], name: "index_cities_on_quiz_id_and_normalized_name", unique: true
    t.index ["quiz_id"], name: "index_cities_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration_seconds", default: 300, null: false
    t.string "region", null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_quizzes_on_slug", unique: true
  end

  add_foreign_key "cities", "quizzes"
end
