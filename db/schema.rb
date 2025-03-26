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

ActiveRecord::Schema[8.0].define(version: 2025_03_26_135957) do
  create_table "notes", force: :cascade do |t|
    t.string "raw_content"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reminders", force: :cascade do |t|
    t.datetime "due_date"
    t.integer "note_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id"], name: "index_reminders_on_note_id"
  end

  add_foreign_key "reminders", "notes"
end
