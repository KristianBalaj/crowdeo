# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_12_095058) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "event_attendances", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_attendances_on_event_id"
    t.index ["user_id"], name: "index_event_attendances_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.date "start_date"
    t.date "end_date"
    t.integer "capacity"
    t.boolean "is_filter"
    t.date "from_birth_date"
    t.string "location_name"
    t.string "location_description"
    t.float "longitude"
    t.float "latitude"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_events_on_author_id"
    t.index ["created_at", "name"], name: "index_events_on_created_at_and_name", order: { created_at: :desc }
    t.index ["name"], name: "index_events_on_name"
  end

  create_table "events_gender_filters", force: :cascade do |t|
    t.integer "event_id"
    t.integer "gender_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_events_gender_filters_on_event_id"
  end

  create_table "genders", force: :cascade do |t|
    t.string "gender_tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "nick_name"
    t.date "birth_date"
    t.string "email"
    t.boolean "calendar_sync"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.integer "gender_id"
  end

  add_foreign_key "event_attendances", "events"
  add_foreign_key "event_attendances", "users"
  add_foreign_key "events", "users", column: "author_id"
  add_foreign_key "events_gender_filters", "events"
  add_foreign_key "events_gender_filters", "genders"
  add_foreign_key "users", "genders"
end
