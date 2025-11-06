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

ActiveRecord::Schema[8.0].define(version: 2025_11_06_081445) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "ltree"
  enable_extension "pg_catalog.plpgsql"

  create_table "authentication_codes", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "expires_at", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_authentication_codes_on_user_id"
  end

  create_table "collections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "label", null: false
    t.string "slug", null: false
    t.bigint "parent_id"
    t.ltree "path", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_collections_on_parent_id"
    t.index ["path"], name: "index_collections_on_path", using: :gist
    t.index ["user_id", "parent_id", "position"], name: "index_collections_on_user_id_and_parent_id_and_position"
    t.index ["user_id", "parent_id", "slug"], name: "index_collections_on_user_id_and_parent_id_and_slug", unique: true
    t.index ["user_id"], name: "index_collections_on_user_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "raw_content"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "collection_id"
    t.index ["collection_id"], name: "index_notes_on_collection_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.datetime "due_date"
    t.integer "note_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "completed", default: false, null: false
    t.index ["note_id"], name: "index_reminders_on_note_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "authentication_codes", "users"
  add_foreign_key "collections", "collections", column: "parent_id", on_delete: :cascade
  add_foreign_key "collections", "users", on_delete: :cascade
  add_foreign_key "notes", "collections"
  add_foreign_key "notes", "users"
  add_foreign_key "reminders", "notes"
end
