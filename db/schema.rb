# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160227230233) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "username",            default: "", null: false
    t.string   "domain"
    t.string   "verify_token",        default: "", null: false
    t.string   "secret",              default: "", null: false
    t.text     "private_key"
    t.text     "public_key",          default: "", null: false
    t.string   "remote_url",          default: "", null: false
    t.string   "salmon_url",          default: "", null: false
    t.string   "hub_url",             default: "", null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.text     "note",                default: "", null: false
    t.string   "display_name",        default: "", null: false
    t.string   "uri",                 default: "", null: false
    t.string   "url"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "accounts", ["username", "domain"], name: "index_accounts_on_username_and_domain", unique: true, using: :btree

  create_table "favourites", force: :cascade do |t|
    t.integer  "account_id", null: false
    t.integer  "status_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "favourites", ["account_id", "status_id"], name: "index_favourites_on_account_id_and_status_id", unique: true, using: :btree

  create_table "follows", force: :cascade do |t|
    t.integer  "account_id",        null: false
    t.integer  "target_account_id", null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "follows", ["account_id", "target_account_id"], name: "index_follows_on_account_id_and_target_account_id", unique: true, using: :btree

  create_table "mentions", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "status_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "mentions", ["account_id", "status_id"], name: "index_mentions_on_account_id_and_status_id", unique: true, using: :btree

  create_table "statuses", force: :cascade do |t|
    t.string   "uri"
    t.integer  "account_id",                  null: false
    t.text     "text",           default: "", null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "in_reply_to_id"
    t.integer  "reblog_of_id"
    t.string   "url"
  end

  add_index "statuses", ["uri"], name: "index_statuses_on_uri", unique: true, using: :btree

  create_table "stream_entries", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "activity_id"
    t.string   "activity_type"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",      default: "", null: false
    t.integer  "account_id",              null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
