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

ActiveRecord::Schema.define(version: 2019_09_16_163826) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "school_id", null: false
    t.integer "visit_id"
    t.string "name", limit: 255, null: false
    t.string "activity_type", null: false
    t.datetime "created_at"
    t.index ["user_id", "activity_type"], name: "index_activities_on_user_id_and_activity_type"
    t.index ["visit_id"], name: "index_activities_on_visit_id"
  end

  create_table "users", id: :bigint, default: nil, force: :cascade do |t|
    t.integer "last_activity_id"
    t.integer "last_visit_id"
  end

  create_table "visits", force: :cascade do |t|
    t.integer "user_id"
    t.integer "school_id"
    t.datetime "start_at"
    t.datetime "stop_at"
    t.integer "seconds"
    t.integer "start_activity_id"
    t.integer "stop_activity_id"
    t.index ["user_id"], name: "index_visits_on_user_id"
  end
end
