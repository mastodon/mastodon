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

ActiveRecord::Schema[7.1].define(version: 2016_02_20_174730) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", id: :serial, force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "domain"
    t.string "verify_token", default: "", null: false
    t.string "secret", default: "", null: false
    t.text "private_key"
    t.text "public_key", default: "", null: false
    t.string "remote_url", default: "", null: false
    t.string "salmon_url", default: "", null: false
    t.string "hub_url", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["username", "domain"], name: "index_accounts_on_username_and_domain", unique: true
  end

end
