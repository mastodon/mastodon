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

ActiveRecord::Schema[7.1].define(version: 2024_05_22_041528) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_aliases", force: :cascade do |t|
    t.bigint "account_id"
    t.string "acct", default: "", null: false
    t.string "uri", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["account_id", "uri"], name: "index_account_aliases_on_account_id_and_uri", unique: true
    t.index ["account_id"], name: "index_account_aliases_on_account_id"
  end

  create_table "account_conversations", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "conversation_id"
    t.bigint "participant_account_ids", default: [], null: false, array: true
    t.bigint "status_ids", default: [], null: false, array: true
    t.bigint "last_status_id"
    t.integer "lock_version", default: 0, null: false
    t.boolean "unread", default: false, null: false
    t.index ["account_id", "conversation_id", "participant_account_ids"], name: "index_unique_conversations", unique: true
    t.index ["conversation_id"], name: "index_account_conversations_on_conversation_id"
  end

  create_table "account_deletion_requests", force: :cascade do |t|
    t.bigint "account_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["account_id"], name: "index_account_deletion_requests_on_account_id"
  end

  create_table "account_domain_blocks", force: :cascade do |t|
    t.string "domain"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "account_id"
    t.index ["account_id", "domain"], name: "index_account_domain_blocks_on_account_id_and_domain", unique: true
  end

  create_table "account_migrations", force: :cascade do |t|
    t.bigint "account_id"
    t.string "acct", default: "", null: false
    t.bigint "followers_count", default: 0, null: false
    t.bigint "target_account_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["account_id"], name: "index_account_migrations_on_account_id"
    t.index ["target_account_id"], name: "index_account_migrations_on_target_account_id", where: "(target_account_id IS NOT NULL)"
  end

  create_table "account_moderation_notes", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "account_id", null: false
    t.bigint "target_account_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["account_id"], name: "index_account_moderation_notes_on_account_id"
    t.index ["target_account_id"], name: "index_account_moderation_notes_on_target_account_id"
  end

  create_table "account_notes", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "target_account_id"
    t.text "comment", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["account_id", "target_account_id"], name: "index_account_notes_on_account_id_and_target_account_id", unique: true
    t.index ["target_account_id"], name: "index_account_notes_on_target_account_id"
  end

  create_table "account_pins", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "target_account_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["account_id", "target_account_id"], name: "index_account_pins_on_account_id_and_target_account_id", unique: true
    t.index ["target_account_id"], name: "index_account_pins_on_target_account_id"
  end

  create_table "account_relationship_severance_events", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "relationship_severance_event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "followers_count", default: 0, null: false
    t.integer "following_count", default: 0, null: false
    t.index ["account_id", "relationship_severance_event_id"], name: "idx_on_account_id_relationship_severance_event_id_7bd82bf20e", unique: true
    t.index ["account_id"], name: "index_account_relationship_severance_events_on_account_id"
    t.index ["relationship_severance_event_id"], name: "idx_on_relationship_severance_event_id_403f53e707"
  end

  create_table "account_stats", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "statuses_count", default: 0, null: false
    t.bigint "following_count", default: 0, null: false
    t.bigint "followers_count", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "last_status_at", precision: nil
    t.index ["account_id"], name: "index_account_stats_on_account_id", unique: true
    t.index ["last_status_at", "account_id"], name: "index_account_stats_on_last_status_at_and_account_id", order: { last_status_at: "DESC NULLS LAST" }
  end

  create_table "account_statuses_cleanup_policies", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.boolean "enabled", default: true, null: false
    t.integer "min_status_age", default: 1209600, null: false
    t.boolean "keep_direct", default: true, null: false
    t.boolean "keep_pinned", default: true, null: false
    t.boolean "keep_polls", default: false, null: false
    t.boolean "keep_media", default: false, null: false
    t.boolean "keep_self_fav", default: true, null: false
    t.boolean "keep_self_bookmark", default: true, null: false
    t.integer "min_favs"
    t.integer "min_reblogs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_statuses_cleanup_policies_on_account_id"
  end

  create_table "account_warning_presets", force: :cascade do |t|
    t.text "text", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "title", default: "", null: false
  end

  create_table "account_warnings", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "target_account_id"
    t.integer "action", default: 0, null: false
    t.text "text", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "report_id"
    t.string "status_ids", array: true
    t.datetime "overruled_at", precision: nil
    t.index ["account_id"], name: "index_account_warnings_on_account_id"
    t.index ["target_account_id"], name: "index_account_warnings_on_target_account_id"
  end

  create_table "accounts", id: :bigint, default: -> { "timestamp_id('accounts'::text)" }, force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "domain"
    t.text "private_key"
    t.text "public_key", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "note", default: "", null: false
    t.string "display_name", default: "", null: false
    t.string "uri", default: "", null: false
    t.string "url"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at", precision: nil
    t.string "header_file_name"
    t.string "header_content_type"
    t.integer "header_file_size"
    t.datetime "header_updated_at", precision: nil
    t.string "avatar_remote_url"
    t.boolean "locked", default: false, null: false
    t.string "header_remote_url", default: "", null: false
    t.datetime "last_webfingered_at", precision: nil
    t.string "inbox_url", default: "", null: false
    t.string "outbox_url", default: "", null: false
    t.string "shared_inbox_url", default: "", null: false
    t.string "followers_url", default: "", null: false
    t.integer "protocol", default: 0, null: false
    t.boolean "memorial", default: false, null: false
    t.bigint "moved_to_account_id"
    t.string "featured_collection_url"
    t.jsonb "fields"
    t.string "actor_type"
    t.boolean "discoverable"
    t.string "also_known_as", array: true
    t.datetime "silenced_at", precision: nil
    t.datetime "suspended_at", precision: nil
    t.boolean "hide_collections"
    t.integer "avatar_storage_schema_version"
    t.integer "header_storage_schema_version"
    t.string "devices_url"
    t.integer "suspension_origin"
    t.datetime "sensitized_at", precision: nil
    t.boolean "trendable"
    t.datetime "reviewed_at", precision: nil
    t.datetime "requested_review_at", precision: nil
    t.boolean "indexable", default: false, null: false
    t.index "(((setweight(to_tsvector('simple'::regconfig, (display_name)::text), 'A'::\"char\") || setweight(to_tsvector('simple'::regconfig, (username)::text), 'B'::\"char\")) || setweight(to_tsvector('simple'::regconfig, (COALESCE(domain, ''::character varying))::text), 'C'::\"char\")))", name: "search_index", using: :gin
    t.index "lower((username)::text), COALESCE(lower((domain)::text), ''::text)", name: "index_accounts_on_username_and_domain_lower", unique: true
    t.index ["domain", "id"], name: "index_accounts_on_domain_and_id"
    t.index ["moved_to_account_id"], name: "index_accounts_on_moved_to_account_id", where: "(moved_to_account_id IS NOT NULL)"
    t.index ["uri"], name: "index_accounts_on_uri"
    t.index ["url"], name: "index_accounts_on_url", opclass: :text_pattern_ops, where: "(url IS NOT NULL)"
  end

  create_table "accounts_tags", primary_key: ["tag_id", "account_id"], force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "tag_id", null: false
    t.index ["account_id", "tag_id"], name: "index_accounts_tags_on_account_id_and_tag_id"
  end

  create_table "admin_action_logs", force: :cascade do |t|
    t.bigint "account_id"
    t.string "action", default: "", null: false
    t.string "target_type"
    t.bigint "target_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "human_identifier"
    t.string "route_param"
    t.string "permalink"
    t.index ["account_id"], name: "index_admin_action_logs_on_account_id"
    t.index ["target_type", "target_id"], name: "index_admin_action_logs_on_target_type_and_target_id"
  end

  create_table "announcement_mutes", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "announcement_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["account_id", "announcement_id"], name: "index_announcement_mutes_on_account_id_and_announcement_id", unique: true
    t.index ["announcement_id"], name: "index_announcement_mutes_on_announcement_id"
  end

  create_table "announcement_reactions", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "announcement_id"
    t.string "name", default: "", null: false
    t.bigint "custom_emoji_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["account_id", "announcement_id", "name"], name: "index_announcement_reactions_on_account_id_and_announcement_id", unique: true
    t.index ["announcement_id"], name: "index_announcement_reactions_on_announcement_id"
    t.index ["custom_emoji_id"], name: "index_announcement_reactions_on_custom_emoji_id", where: "(custom_emoji_id IS NOT NULL)"
  end

  create_table "announcements", force: :cascade do |t|
    t.text "text", default: "", null: false
    t.boolean "published", default: false, null: false
    t.boolean "all_day", default: false, null: false
    t.datetime "scheduled_at", precision: nil
    t.datetime "starts_at", precision: nil
    t.datetime "ends_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "published_at", precision: nil
    t.bigint "status_ids", array: true
  end

  create_table "appeals", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "account_warning_id", null: false
    t.text "text", default: "", null: false
    t.datetime "approved_at", precision: nil
    t.bigint "approved_by_account_id"
    t.datetime "rejected_at", precision: nil
    t.bigint "rejected_by_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_appeals_on_account_id"
    t.index ["account_warning_id"], name: "index_appeals_on_account_warning_id", unique: true
    t.index ["approved_by_account_id"], name: "index_appeals_on_approved_by_account_id", where: "(approved_by_account_id IS NOT NULL)"
    t.index ["rejected_by_account_id"], name: "index_appeals_on_rejected_by_account_id", where: "(rejected_by_account_id IS NOT NULL)"
  end

  create_table "backups", force: :cascade do |t|
    t.bigint "user_id"
    t.string "dump_file_name"
    t.string "dump_content_type"
    t.datetime "dump_updated_at", precision: nil
    t.boolean "processed", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "dump_file_size"
    t.index ["user_id"], name: "index_backups_on_user_id"
  end

  create_table "blocks", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "account_id", null: false
    t.bigint "target_account_id", null: false
    t.string "uri"
    t.index ["account_id", "target_account_id"], name: "index_blocks_on_account_id_and_target_account_id", unique: true
    t.index ["target_account_id"], name: "index_blocks_on_target_account_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "status_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["account_id", "status_id"], name: "index_bookmarks_on_account_id_and_status_id", unique: true
    t.index ["status_id"], name: "index_bookmarks_on_status_id"
  end

  create_table "bulk_import_rows", force: :cascade do |t|
    t.bigint "bulk_import_id", null: false
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bulk_import_id"], name: "index_bulk_import_rows_on_bulk_import_id"
  end

  create_table "bulk_imports", force: :cascade do |t|
    t.integer "type", null: false
    t.integer "state", null: false
    t.integer "total_items", default: 0, null: false
    t.integer "imported_items", default: 0, null: false
    t.integer "processed_items", default: 0, null: false
    t.datetime "finished_at", precision: nil
    t.boolean "overwrite", default: false, null: false
    t.boolean "likely_mismatched", default: false, null: false
    t.string "original_filename", default: "", null: false
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_bulk_imports_on_account_id"
    t.index ["id"], name: "index_bulk_imports_unconfirmed", where: "(state = 0)"
  end

  create_table "canonical_email_blocks", force: :cascade do |t|
    t.string "canonical_email_hash", default: "", null: false
    t.bigint "reference_account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["canonical_email_hash"], name: "index_canonical_email_blocks_on_canonical_email_hash", unique: true
    t.index ["reference_account_id"], name: "index_canonical_email_blocks_on_reference_account_id"
  end

  create_table "conversation_mutes", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "account_id", null: false
    t.index ["account_id", "conversation_id"], name: "index_conversation_mutes_on_account_id_and_conversation_id", unique: true
  end

  create_table "conversations", force: :cascade do |t|
    t.string "uri"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["uri"], name: "index_conversations_on_uri", unique: true, opclass: :text_pattern_ops, where: "(uri IS NOT NULL)"
  end

  create_table "custom_emoji_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["name"], name: "index_custom_emoji_categories_on_name", unique: true
  end

  create_table "custom_emojis", force: :cascade do |t|
    t.string "shortcode", default: "", null: false
    t.string "domain"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "disabled", default: false, null: false
    t.string "uri"
    t.string "image_remote_url"
    t.boolean "visible_in_picker", default: true, null: false
    t.bigint "category_id"
    t.integer "image_storage_schema_version"
    t.index ["shortcode", "domain"], name: "index_custom_emojis_on_shortcode_and_domain", unique: true
  end

  create_table "custom_filter_keywords", force: :cascade do |t|
    t.bigint "custom_filter_id", null: false
    t.text "keyword", default: "", null: false
    t.boolean "whole_word", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_filter_id"], name: "index_custom_filter_keywords_on_custom_filter_id"
  end

  create_table "custom_filter_statuses", force: :cascade do |t|
    t.bigint "custom_filter_id", null: false
    t.bigint "status_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_filter_id"], name: "index_custom_filter_statuses_on_custom_filter_id"
    t.index ["status_id", "custom_filter_id"], name: "index_custom_filter_statuses_on_status_id_and_custom_filter_id", unique: true
    t.index ["status_id"], name: "index_custom_filter_statuses_on_status_id"
  end

  create_table "custom_filters", force: :cascade do |t|
    t.bigint "account_id"
    t.datetime "expires_at", precision: nil
    t.text "phrase", default: "", null: false
    t.string "context", default: [], null: false, array: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "action", default: 0, null: false
    t.index ["account_id"], name: "index_custom_filters_on_account_id"
  end

  create_table "devices", force: :cascade do |t|
    t.bigint "access_token_id"
    t.bigint "account_id"
    t.string "device_id", default: "", null: false
    t.string "name", default: "", null: false
    t.text "fingerprint_key", default: "", null: false
    t.text "identity_key", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["access_token_id"], name: "index_devices_on_access_token_id"
    t.index ["account_id"], name: "index_devices_on_account_id"
  end

  create_table "domain_allows", force: :cascade do |t|
    t.string "domain", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["domain"], name: "index_domain_allows_on_domain", unique: true
  end

  create_table "domain_blocks", force: :cascade do |t|
    t.string "domain", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "severity", default: 0
    t.boolean "reject_media", default: false, null: false
    t.boolean "reject_reports", default: false, null: false
    t.text "private_comment"
    t.text "public_comment"
    t.boolean "obfuscate", default: false, null: false
    t.index ["domain"], name: "index_domain_blocks_on_domain", unique: true
  end

  create_table "email_domain_blocks", force: :cascade do |t|
    t.string "domain", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "parent_id"
    t.boolean "allow_with_approval", default: false, null: false
    t.index ["domain"], name: "index_email_domain_blocks_on_domain", unique: true
  end

  create_table "encrypted_messages", id: :bigint, default: -> { "timestamp_id('encrypted_messages'::text)" }, force: :cascade do |t|
    t.bigint "device_id"
    t.bigint "from_account_id"
    t.string "from_device_id", default: "", null: false
    t.integer "type", default: 0, null: false
    t.text "body", default: "", null: false
    t.text "digest", default: "", null: false
    t.text "message_franking", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["device_id"], name: "index_encrypted_messages_on_device_id"
    t.index ["from_account_id"], name: "index_encrypted_messages_on_from_account_id"
  end

  create_table "favourites", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "account_id", null: false
    t.bigint "status_id", null: false
    t.index ["account_id", "id"], name: "index_favourites_on_account_id_and_id"
    t.index ["account_id", "status_id"], name: "index_favourites_on_account_id_and_status_id", unique: true
    t.index ["status_id"], name: "index_favourites_on_status_id"
  end

  create_table "featured_tags", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "tag_id", null: false
    t.bigint "statuses_count", default: 0, null: false
    t.datetime "last_status_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "name"
    t.index ["account_id", "tag_id"], name: "index_featured_tags_on_account_id_and_tag_id", unique: true
    t.index ["tag_id"], name: "index_featured_tags_on_tag_id"
  end

  create_table "follow_recommendation_mutes", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "target_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "target_account_id"], name: "idx_on_account_id_target_account_id_a8c8ddf44e", unique: true
    t.index ["target_account_id"], name: "index_follow_recommendation_mutes_on_target_account_id"
  end

  create_table "follow_recommendation_suppressions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_follow_recommendation_suppressions_on_account_id", unique: true
  end

  create_table "follow_requests", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "account_id", null: false
    t.bigint "target_account_id", null: false
    t.boolean "show_reblogs", default: true, null: false
    t.string "uri"
    t.boolean "notify", default: false, null: false
    t.string "languages", array: true
    t.index ["account_id", "target_account_id"], name: "index_follow_requests_on_account_id_and_target_account_id", unique: true
  end

  create_table "follows", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "account_id", null: false
    t.bigint "target_account_id", null: false
    t.boolean "show_reblogs", default: true, null: false
    t.string "uri"
    t.boolean "notify", default: false, null: false
    t.string "languages", array: true
    t.index ["account_id", "target_account_id"], name: "index_follows_on_account_id_and_target_account_id", unique: true
    t.index ["target_account_id"], name: "index_follows_on_target_account_id"
  end

  create_table "generated_annual_reports", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.integer "year", null: false
    t.jsonb "data", null: false
    t.integer "schema_version", null: false
    t.datetime "viewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "year"], name: "index_generated_annual_reports_on_account_id_and_year", unique: true
  end

  create_table "identities", force: :cascade do |t|
    t.string "provider", default: "", null: false
    t.string "uid", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.index ["uid", "provider"], name: "index_identities_on_uid_and_provider", unique: true
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "imports", force: :cascade do |t|
    t.integer "type", null: false
    t.boolean "approved", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "data_file_name"
    t.string "data_content_type"
    t.integer "data_file_size"
    t.datetime "data_updated_at", precision: nil
    t.bigint "account_id", null: false
    t.boolean "overwrite", default: false, null: false
  end

  create_table "invites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "code", default: "", null: false
    t.datetime "expires_at", precision: nil
    t.integer "max_uses"
    t.integer "uses", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "autofollow", default: false, null: false
    t.text "comment"
    t.index ["code"], name: "index_invites_on_code", unique: true
    t.index ["user_id"], name: "index_invites_on_user_id"
  end

  create_table "ip_blocks", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil
    t.inet "ip", default: "0.0.0.0", null: false
    t.integer "severity", default: 0, null: false
    t.text "comment", default: "", null: false
    t.index ["ip"], name: "index_ip_blocks_on_ip", unique: true
  end

  create_table "list_accounts", force: :cascade do |t|
    t.bigint "list_id", null: false
    t.bigint "account_id", null: false
    t.bigint "follow_id"
    t.bigint "follow_request_id"
    t.index ["account_id", "list_id"], name: "index_list_accounts_on_account_id_and_list_id", unique: true
    t.index ["follow_id"], name: "index_list_accounts_on_follow_id", where: "(follow_id IS NOT NULL)"
    t.index ["follow_request_id"], name: "index_list_accounts_on_follow_request_id", where: "(follow_request_id IS NOT NULL)"
    t.index ["list_id", "account_id"], name: "index_list_accounts_on_list_id_and_account_id"
  end

  create_table "lists", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "title", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "replies_policy", default: 0, null: false
    t.boolean "exclusive", default: false, null: false
    t.index ["account_id"], name: "index_lists_on_account_id"
  end

  create_table "login_activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "authentication_method"
    t.string "provider"
    t.boolean "success"
    t.string "failure_reason"
    t.inet "ip"
    t.string "user_agent"
    t.datetime "created_at", precision: nil
    t.index ["user_id"], name: "index_login_activities_on_user_id"
  end

  create_table "markers", force: :cascade do |t|
    t.bigint "user_id"
    t.string "timeline", default: "", null: false
    t.bigint "last_read_id", default: 0, null: false
    t.integer "lock_version", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id", "timeline"], name: "index_markers_on_user_id_and_timeline", unique: true
  end

  create_table "media_attachments", id: :bigint, default: -> { "timestamp_id('media_attachments'::text)" }, force: :cascade do |t|
    t.bigint "status_id"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at", precision: nil
    t.string "remote_url", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "shortcode"
    t.integer "type", default: 0, null: false
    t.json "file_meta"
    t.bigint "account_id"
    t.text "description"
    t.bigint "scheduled_status_id"
    t.string "blurhash"
    t.integer "processing"
    t.integer "file_storage_schema_version"
    t.string "thumbnail_file_name"
    t.string "thumbnail_content_type"
    t.integer "thumbnail_file_size"
    t.datetime "thumbnail_updated_at", precision: nil
    t.string "thumbnail_remote_url"
    t.index ["account_id", "status_id"], name: "index_media_attachments_on_account_id_and_status_id", order: { status_id: :desc }
    t.index ["scheduled_status_id"], name: "index_media_attachments_on_scheduled_status_id", where: "(scheduled_status_id IS NOT NULL)"
    t.index ["shortcode"], name: "index_media_attachments_on_shortcode", unique: true, opclass: :text_pattern_ops, where: "(shortcode IS NOT NULL)"
    t.index ["status_id"], name: "index_media_attachments_on_status_id"
  end

  create_table "mentions", force: :cascade do |t|
    t.bigint "status_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "account_id"
    t.boolean "silent", default: false, null: false
    t.index ["account_id", "status_id"], name: "index_mentions_on_account_id_and_status_id", unique: true
    t.index ["status_id"], name: "index_mentions_on_status_id"
  end

  create_table "mutes", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "hide_notifications", default: true, null: false
    t.bigint "account_id", null: false
    t.bigint "target_account_id", null: false
    t.datetime "expires_at", precision: nil
    t.index ["account_id", "target_account_id"], name: "index_mutes_on_account_id_and_target_account_id", unique: true
    t.index ["target_account_id"], name: "index_mutes_on_target_account_id"
  end

  create_table "notification_permissions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "from_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_notification_permissions_on_account_id"
    t.index ["from_account_id"], name: "index_notification_permissions_on_from_account_id"
  end

  create_table "notification_policies", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.boolean "filter_not_following", default: false, null: false
    t.boolean "filter_not_followers", default: false, null: false
    t.boolean "filter_new_accounts", default: false, null: false
    t.boolean "filter_private_mentions", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_notification_policies_on_account_id", unique: true
  end

  create_table "notification_requests", id: :bigint, default: -> { "timestamp_id('notification_requests'::text)" }, force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "from_account_id", null: false
    t.bigint "last_status_id"
    t.bigint "notifications_count", default: 0, null: false
    t.boolean "dismissed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "from_account_id"], name: "index_notification_requests_on_account_id_and_from_account_id", unique: true
    t.index ["account_id", "id"], name: "index_notification_requests_on_account_id_and_id", order: { id: :desc }, where: "(dismissed = false)"
    t.index ["from_account_id"], name: "index_notification_requests_on_from_account_id"
    t.index ["last_status_id"], name: "index_notification_requests_on_last_status_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "activity_id", null: false
    t.string "activity_type", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "account_id", null: false
    t.bigint "from_account_id", null: false
    t.string "type"
    t.boolean "filtered", default: false, null: false
    t.index ["account_id", "id", "type"], name: "index_notifications_on_account_id_and_id_and_type", order: { id: :desc }
    t.index ["account_id", "id", "type"], name: "index_notifications_on_filtered", order: { id: :desc }, where: "(filtered = false)"
    t.index ["activity_id", "activity_type"], name: "index_notifications_on_activity_id_and_activity_type"
    t.index ["from_account_id"], name: "index_notifications_on_from_account_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.bigint "application_id", null: false
    t.bigint "resource_owner_id", null: false
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "scopes"
    t.bigint "application_id"
    t.bigint "resource_owner_id"
    t.datetime "last_used_at", precision: nil
    t.inet "last_used_ip"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, opclass: :text_pattern_ops, where: "(refresh_token IS NOT NULL)"
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", where: "(resource_owner_id IS NOT NULL)"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "superapp", default: false, null: false
    t.string "website"
    t.string "owner_type"
    t.bigint "owner_id"
    t.boolean "confidential", default: true, null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["superapp"], name: "index_oauth_applications_on_superapp", where: "(superapp = true)"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "one_time_keys", force: :cascade do |t|
    t.bigint "device_id"
    t.string "key_id", default: "", null: false
    t.text "key", default: "", null: false
    t.text "signature", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["device_id"], name: "index_one_time_keys_on_device_id"
    t.index ["key_id"], name: "index_one_time_keys_on_key_id"
  end

  create_table "pghero_space_stats", force: :cascade do |t|
    t.text "database"
    t.text "schema"
    t.text "relation"
    t.bigint "size"
    t.datetime "captured_at", precision: nil
    t.index ["database", "captured_at"], name: "index_pghero_space_stats_on_database_and_captured_at"
  end

  create_table "poll_votes", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "poll_id"
    t.integer "choice", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "uri"
    t.index ["account_id"], name: "index_poll_votes_on_account_id"
    t.index ["poll_id"], name: "index_poll_votes_on_poll_id"
  end

  create_table "polls", force: :cascade do |t|
    t.bigint "account_id"
    t.bigint "status_id"
    t.datetime "expires_at", precision: nil
    t.string "options", default: [], null: false, array: true
    t.bigint "cached_tallies", default: [], null: false, array: true
    t.boolean "multiple", default: false, null: false
    t.boolean "hide_totals", default: false, null: false
    t.bigint "votes_count", default: 0, null: false
    t.datetime "last_fetched_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "lock_version", default: 0, null: false
    t.bigint "voters_count"
    t.index ["account_id"], name: "index_polls_on_account_id"
    t.index ["status_id"], name: "index_polls_on_status_id"
  end

  create_table "preview_card_providers", force: :cascade do |t|
    t.string "domain", default: "", null: false
    t.string "icon_file_name"
    t.string "icon_content_type"
    t.bigint "icon_file_size"
    t.datetime "icon_updated_at", precision: nil
    t.boolean "trendable"
    t.datetime "reviewed_at", precision: nil
    t.datetime "requested_review_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["domain"], name: "index_preview_card_providers_on_domain", unique: true
  end

  create_table "preview_card_trends", force: :cascade do |t|
    t.bigint "preview_card_id", null: false
    t.float "score", default: 0.0, null: false
    t.integer "rank", default: 0, null: false
    t.boolean "allowed", default: false, null: false
    t.string "language"
    t.index ["preview_card_id"], name: "index_preview_card_trends_on_preview_card_id", unique: true
  end

  create_table "preview_cards", force: :cascade do |t|
    t.string "url", default: "", null: false
    t.string "title", default: "", null: false
    t.string "description", default: "", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at", precision: nil
    t.integer "type", default: 0, null: false
    t.text "html", default: "", null: false
    t.string "author_name", default: "", null: false
    t.string "author_url", default: "", null: false
    t.string "provider_name", default: "", null: false
    t.string "provider_url", default: "", null: false
    t.integer "width", default: 0, null: false
    t.integer "height", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "embed_url", default: "", null: false
    t.integer "image_storage_schema_version"
    t.string "blurhash"
    t.string "language"
    t.float "max_score"
    t.datetime "max_score_at", precision: nil
    t.boolean "trendable"
    t.integer "link_type"
    t.datetime "published_at"
    t.string "image_description", default: "", null: false
    t.bigint "author_account_id"
    t.index ["author_account_id"], name: "index_preview_cards_on_author_account_id", where: "(author_account_id IS NOT NULL)"
    t.index ["url"], name: "index_preview_cards_on_url", unique: true
  end

  create_table "preview_cards_statuses", primary_key: ["status_id", "preview_card_id"], force: :cascade do |t|
    t.bigint "preview_card_id", null: false
    t.bigint "status_id", null: false
    t.string "url"
  end

  create_table "relationship_severance_events", force: :cascade do |t|
    t.integer "type", null: false
    t.string "target_name", null: false
    t.boolean "purged", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type", "target_name"], name: "index_relationship_severance_events_on_type_and_target_name"
  end

  create_table "relays", force: :cascade do |t|
    t.string "inbox_url", default: "", null: false
    t.string "follow_activity_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "state", default: 0, null: false
  end

  create_table "report_notes", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "report_id", null: false
    t.bigint "account_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["account_id"], name: "index_report_notes_on_account_id"
    t.index ["report_id"], name: "index_report_notes_on_report_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "status_ids", default: [], null: false, array: true
    t.text "comment", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "account_id", null: false
    t.bigint "action_taken_by_account_id"
    t.bigint "target_account_id", null: false
    t.bigint "assigned_account_id"
    t.string "uri"
    t.boolean "forwarded"
    t.integer "category", default: 0, null: false
    t.datetime "action_taken_at", precision: nil
    t.bigint "rule_ids", array: true
    t.index ["account_id"], name: "index_reports_on_account_id"
    t.index ["action_taken_by_account_id"], name: "index_reports_on_action_taken_by_account_id", where: "(action_taken_by_account_id IS NOT NULL)"
    t.index ["assigned_account_id"], name: "index_reports_on_assigned_account_id", where: "(assigned_account_id IS NOT NULL)"
    t.index ["target_account_id"], name: "index_reports_on_target_account_id"
  end

  create_table "rules", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.datetime "deleted_at", precision: nil
    t.text "text", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "hint", default: "", null: false
  end

  create_table "scheduled_statuses", force: :cascade do |t|
    t.bigint "account_id"
    t.datetime "scheduled_at", precision: nil
    t.jsonb "params"
    t.index ["account_id"], name: "index_scheduled_statuses_on_account_id"
    t.index ["scheduled_at"], name: "index_scheduled_statuses_on_scheduled_at"
  end

  create_table "session_activations", force: :cascade do |t|
    t.string "session_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "user_agent", default: "", null: false
    t.inet "ip"
    t.bigint "access_token_id"
    t.bigint "user_id", null: false
    t.bigint "web_push_subscription_id"
    t.index ["access_token_id"], name: "index_session_activations_on_access_token_id"
    t.index ["session_id"], name: "index_session_activations_on_session_id", unique: true
    t.index ["user_id"], name: "index_session_activations_on_user_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.string "thing_type"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.bigint "thing_id"
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true
  end

  create_table "severed_relationships", force: :cascade do |t|
    t.bigint "relationship_severance_event_id", null: false
    t.bigint "local_account_id", null: false
    t.bigint "remote_account_id", null: false
    t.integer "direction", null: false
    t.boolean "show_reblogs"
    t.boolean "notify"
    t.string "languages", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["local_account_id", "relationship_severance_event_id"], name: "index_severed_relationships_on_local_account_and_event"
    t.index ["relationship_severance_event_id", "local_account_id", "direction", "remote_account_id"], name: "index_severed_relationships_on_unique_tuples", unique: true
    t.index ["remote_account_id"], name: "index_severed_relationships_on_remote_account_id"
  end

  create_table "site_uploads", force: :cascade do |t|
    t.string "var", default: "", null: false
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at", precision: nil
    t.json "meta"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "blurhash"
    t.index ["var"], name: "index_site_uploads_on_var", unique: true
  end

  create_table "software_updates", force: :cascade do |t|
    t.string "version", null: false
    t.boolean "urgent", default: false, null: false
    t.integer "type", default: 0, null: false
    t.string "release_notes", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["version"], name: "index_software_updates_on_version", unique: true
  end

  create_table "status_edits", force: :cascade do |t|
    t.bigint "status_id", null: false
    t.bigint "account_id"
    t.text "text", default: "", null: false
    t.text "spoiler_text", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "content_type"
    t.bigint "ordered_media_attachment_ids", array: true
    t.text "media_descriptions", array: true
    t.string "poll_options", array: true
    t.boolean "sensitive"
    t.index ["account_id"], name: "index_status_edits_on_account_id"
    t.index ["status_id"], name: "index_status_edits_on_status_id"
  end

  create_table "status_pins", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "status_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["account_id", "status_id"], name: "index_status_pins_on_account_id_and_status_id", unique: true
    t.index ["status_id"], name: "index_status_pins_on_status_id"
  end

  create_table "status_stats", force: :cascade do |t|
    t.bigint "status_id", null: false
    t.bigint "replies_count", default: 0, null: false
    t.bigint "reblogs_count", default: 0, null: false
    t.bigint "favourites_count", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["status_id"], name: "index_status_stats_on_status_id", unique: true
  end

  create_table "status_trends", force: :cascade do |t|
    t.bigint "status_id", null: false
    t.bigint "account_id", null: false
    t.float "score", default: 0.0, null: false
    t.integer "rank", default: 0, null: false
    t.boolean "allowed", default: false, null: false
    t.string "language"
    t.index ["account_id"], name: "index_status_trends_on_account_id"
    t.index ["status_id"], name: "index_status_trends_on_status_id", unique: true
  end

  create_table "statuses", id: :bigint, default: -> { "timestamp_id('statuses'::text)" }, force: :cascade do |t|
    t.string "uri"
    t.text "text", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "in_reply_to_id"
    t.bigint "reblog_of_id"
    t.string "url"
    t.boolean "sensitive", default: false, null: false
    t.integer "visibility", default: 0, null: false
    t.text "spoiler_text", default: "", null: false
    t.boolean "reply", default: false, null: false
    t.string "language"
    t.bigint "conversation_id"
    t.boolean "local"
    t.bigint "account_id", null: false
    t.bigint "application_id"
    t.bigint "in_reply_to_account_id"
    t.boolean "local_only"
    t.bigint "poll_id"
    t.string "content_type"
    t.datetime "deleted_at", precision: nil
    t.datetime "edited_at", precision: nil
    t.boolean "trendable"
    t.bigint "ordered_media_attachment_ids", array: true
    t.index ["account_id", "id", "visibility", "updated_at"], name: "index_statuses_20190820", order: { id: :desc }, where: "(deleted_at IS NULL)"
    t.index ["account_id"], name: "index_statuses_on_account_id"
    t.index ["deleted_at"], name: "index_statuses_on_deleted_at", where: "(deleted_at IS NOT NULL)"
    t.index ["id", "account_id"], name: "index_statuses_local_20190824", order: { id: :desc }, where: "((local OR (uri IS NULL)) AND (deleted_at IS NULL) AND (visibility = 0) AND (reblog_of_id IS NULL) AND ((NOT reply) OR (in_reply_to_account_id = account_id)))"
    t.index ["id", "account_id"], name: "index_statuses_public_20200119", order: { id: :desc }, where: "((deleted_at IS NULL) AND (visibility = 0) AND (reblog_of_id IS NULL) AND ((NOT reply) OR (in_reply_to_account_id = account_id)))"
    t.index ["in_reply_to_account_id"], name: "index_statuses_on_in_reply_to_account_id", where: "(in_reply_to_account_id IS NOT NULL)"
    t.index ["in_reply_to_id"], name: "index_statuses_on_in_reply_to_id", where: "(in_reply_to_id IS NOT NULL)"
    t.index ["reblog_of_id", "account_id"], name: "index_statuses_on_reblog_of_id_and_account_id"
    t.index ["uri"], name: "index_statuses_on_uri", unique: true, opclass: :text_pattern_ops, where: "(uri IS NOT NULL)"
  end

  create_table "statuses_tags", primary_key: ["tag_id", "status_id"], force: :cascade do |t|
    t.bigint "status_id", null: false
    t.bigint "tag_id", null: false
    t.index ["status_id"], name: "index_statuses_tags_on_status_id"
  end

  create_table "system_keys", force: :cascade do |t|
    t.binary "key"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "tag_follows", force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "tag_id"], name: "index_tag_follows_on_account_id_and_tag_id", unique: true
    t.index ["tag_id"], name: "index_tag_follows_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "usable"
    t.boolean "trendable"
    t.boolean "listable"
    t.datetime "reviewed_at", precision: nil
    t.datetime "requested_review_at", precision: nil
    t.datetime "last_status_at", precision: nil
    t.float "max_score"
    t.datetime "max_score_at", precision: nil
    t.string "display_name"
    t.index "lower((name)::text) text_pattern_ops", name: "index_tags_on_name_lower_btree", unique: true
  end

  create_table "tombstones", force: :cascade do |t|
    t.bigint "account_id"
    t.string "uri", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "by_moderator"
    t.index ["account_id"], name: "index_tombstones_on_account_id"
    t.index ["uri"], name: "index_tombstones_on_uri"
  end

  create_table "unavailable_domains", force: :cascade do |t|
    t.string "domain", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["domain"], name: "index_unavailable_domains_on_domain", unique: true
  end

  create_table "user_invite_requests", force: :cascade do |t|
    t.bigint "user_id"
    t.text "text"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_user_invite_requests_on_user_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "color", default: "", null: false
    t.integer "position", default: 0, null: false
    t.bigint "permissions", default: 0, null: false
    t.boolean "highlighted", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.string "locale"
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login", default: false, null: false
    t.datetime "last_emailed_at", precision: nil
    t.string "otp_backup_codes", array: true
    t.bigint "account_id", null: false
    t.boolean "disabled", default: false, null: false
    t.bigint "invite_id"
    t.string "chosen_languages", array: true
    t.bigint "created_by_application_id"
    t.boolean "approved", default: true, null: false
    t.string "sign_in_token"
    t.datetime "sign_in_token_sent_at", precision: nil
    t.string "webauthn_id"
    t.inet "sign_up_ip"
    t.boolean "skip_sign_in_token"
    t.bigint "role_id"
    t.text "settings"
    t.string "time_zone"
    t.string "otp_secret"
    t.index ["account_id"], name: "index_users_on_account_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["created_by_application_id"], name: "index_users_on_created_by_application_id", where: "(created_by_application_id IS NOT NULL)"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, opclass: :text_pattern_ops, where: "(reset_password_token IS NOT NULL)"
    t.index ["role_id"], name: "index_users_on_role_id", where: "(role_id IS NOT NULL)"
    t.index ["unconfirmed_email"], name: "index_users_on_unconfirmed_email", where: "(unconfirmed_email IS NOT NULL)"
  end

  create_table "web_push_subscriptions", force: :cascade do |t|
    t.string "endpoint", null: false
    t.string "key_p256dh", null: false
    t.string "key_auth", null: false
    t.json "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "access_token_id"
    t.bigint "user_id"
    t.index ["access_token_id"], name: "index_web_push_subscriptions_on_access_token_id", where: "(access_token_id IS NOT NULL)"
    t.index ["user_id"], name: "index_web_push_subscriptions_on_user_id"
  end

  create_table "web_settings", force: :cascade do |t|
    t.json "data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_web_settings_on_user_id", unique: true
  end

  create_table "webauthn_credentials", force: :cascade do |t|
    t.string "external_id", null: false
    t.string "public_key", null: false
    t.string "nickname", null: false
    t.bigint "sign_count", default: 0, null: false
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["external_id"], name: "index_webauthn_credentials_on_external_id", unique: true
    t.index ["user_id", "nickname"], name: "index_webauthn_credentials_on_user_id_and_nickname", unique: true
    t.index ["user_id"], name: "index_webauthn_credentials_on_user_id"
  end

  create_table "webhooks", force: :cascade do |t|
    t.string "url", null: false
    t.string "events", default: [], null: false, array: true
    t.string "secret", default: "", null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "template"
    t.index ["url"], name: "index_webhooks_on_url", unique: true
  end

  add_foreign_key "account_aliases", "accounts", on_delete: :cascade
  add_foreign_key "account_conversations", "accounts", on_delete: :cascade
  add_foreign_key "account_conversations", "conversations", on_delete: :cascade
  add_foreign_key "account_deletion_requests", "accounts", on_delete: :cascade
  add_foreign_key "account_domain_blocks", "accounts", name: "fk_206c6029bd", on_delete: :cascade
  add_foreign_key "account_migrations", "accounts", column: "target_account_id", on_delete: :nullify
  add_foreign_key "account_migrations", "accounts", on_delete: :cascade
  add_foreign_key "account_moderation_notes", "accounts"
  add_foreign_key "account_moderation_notes", "accounts", column: "target_account_id"
  add_foreign_key "account_notes", "accounts", column: "target_account_id", on_delete: :cascade
  add_foreign_key "account_notes", "accounts", on_delete: :cascade
  add_foreign_key "account_pins", "accounts", column: "target_account_id", on_delete: :cascade
  add_foreign_key "account_pins", "accounts", on_delete: :cascade
  add_foreign_key "account_relationship_severance_events", "accounts", on_delete: :cascade
  add_foreign_key "account_relationship_severance_events", "relationship_severance_events", on_delete: :cascade
  add_foreign_key "account_stats", "accounts", on_delete: :cascade
  add_foreign_key "account_statuses_cleanup_policies", "accounts", on_delete: :cascade
  add_foreign_key "account_warnings", "accounts", column: "target_account_id", on_delete: :cascade
  add_foreign_key "account_warnings", "accounts", on_delete: :nullify
  add_foreign_key "account_warnings", "reports", on_delete: :cascade
  add_foreign_key "accounts", "accounts", column: "moved_to_account_id", on_delete: :nullify
  add_foreign_key "admin_action_logs", "accounts", on_delete: :cascade
  add_foreign_key "announcement_mutes", "accounts", on_delete: :cascade
  add_foreign_key "announcement_mutes", "announcements", on_delete: :cascade
  add_foreign_key "announcement_reactions", "accounts", on_delete: :cascade
  add_foreign_key "announcement_reactions", "announcements", on_delete: :cascade
  add_foreign_key "announcement_reactions", "custom_emojis", on_delete: :cascade
  add_foreign_key "appeals", "account_warnings", on_delete: :cascade
  add_foreign_key "appeals", "accounts", column: "approved_by_account_id", on_delete: :nullify
  add_foreign_key "appeals", "accounts", column: "rejected_by_account_id", on_delete: :nullify
  add_foreign_key "appeals", "accounts", on_delete: :cascade
  add_foreign_key "backups", "users", on_delete: :nullify
  add_foreign_key "blocks", "accounts", column: "target_account_id", name: "fk_9571bfabc1", on_delete: :cascade
  add_foreign_key "blocks", "accounts", name: "fk_4269e03e65", on_delete: :cascade
  add_foreign_key "bookmarks", "accounts", on_delete: :cascade
  add_foreign_key "bookmarks", "statuses", on_delete: :cascade
  add_foreign_key "bulk_import_rows", "bulk_imports", on_delete: :cascade
  add_foreign_key "bulk_imports", "accounts", on_delete: :cascade
  add_foreign_key "canonical_email_blocks", "accounts", column: "reference_account_id", on_delete: :cascade
  add_foreign_key "conversation_mutes", "accounts", name: "fk_225b4212bb", on_delete: :cascade
  add_foreign_key "conversation_mutes", "conversations", on_delete: :cascade
  add_foreign_key "custom_filter_keywords", "custom_filters", on_delete: :cascade
  add_foreign_key "custom_filter_statuses", "custom_filters", on_delete: :cascade
  add_foreign_key "custom_filter_statuses", "statuses", on_delete: :cascade
  add_foreign_key "custom_filters", "accounts", on_delete: :cascade
  add_foreign_key "devices", "accounts", on_delete: :cascade
  add_foreign_key "devices", "oauth_access_tokens", column: "access_token_id", on_delete: :cascade
  add_foreign_key "email_domain_blocks", "email_domain_blocks", column: "parent_id", on_delete: :cascade
  add_foreign_key "encrypted_messages", "accounts", column: "from_account_id", on_delete: :cascade
  add_foreign_key "encrypted_messages", "devices", on_delete: :cascade
  add_foreign_key "favourites", "accounts", name: "fk_5eb6c2b873", on_delete: :cascade
  add_foreign_key "favourites", "statuses", name: "fk_b0e856845e", on_delete: :cascade
  add_foreign_key "featured_tags", "accounts", on_delete: :cascade
  add_foreign_key "featured_tags", "tags", on_delete: :cascade
  add_foreign_key "follow_recommendation_mutes", "accounts", column: "target_account_id", on_delete: :cascade
  add_foreign_key "follow_recommendation_mutes", "accounts", on_delete: :cascade
  add_foreign_key "follow_recommendation_suppressions", "accounts", on_delete: :cascade
  add_foreign_key "follow_requests", "accounts", column: "target_account_id", name: "fk_9291ec025d", on_delete: :cascade
  add_foreign_key "follow_requests", "accounts", name: "fk_76d644b0e7", on_delete: :cascade
  add_foreign_key "follows", "accounts", column: "target_account_id", name: "fk_745ca29eac", on_delete: :cascade
  add_foreign_key "follows", "accounts", name: "fk_32ed1b5560", on_delete: :cascade
  add_foreign_key "generated_annual_reports", "accounts"
  add_foreign_key "identities", "users", name: "fk_bea040f377", on_delete: :cascade
  add_foreign_key "imports", "accounts", name: "fk_6db1b6e408", on_delete: :cascade
  add_foreign_key "invites", "users", on_delete: :cascade
  add_foreign_key "list_accounts", "accounts", on_delete: :cascade
  add_foreign_key "list_accounts", "follow_requests", on_delete: :cascade
  add_foreign_key "list_accounts", "follows", on_delete: :cascade
  add_foreign_key "list_accounts", "lists", on_delete: :cascade
  add_foreign_key "lists", "accounts", on_delete: :cascade
  add_foreign_key "login_activities", "users", on_delete: :cascade
  add_foreign_key "markers", "users", on_delete: :cascade
  add_foreign_key "media_attachments", "accounts", name: "fk_96dd81e81b", on_delete: :nullify
  add_foreign_key "media_attachments", "scheduled_statuses", on_delete: :nullify
  add_foreign_key "media_attachments", "statuses", on_delete: :nullify
  add_foreign_key "mentions", "accounts", name: "fk_970d43f9d1", on_delete: :cascade
  add_foreign_key "mentions", "statuses", on_delete: :cascade
  add_foreign_key "mutes", "accounts", column: "target_account_id", name: "fk_eecff219ea", on_delete: :cascade
  add_foreign_key "mutes", "accounts", name: "fk_b8d8daf315", on_delete: :cascade
  add_foreign_key "notification_permissions", "accounts"
  add_foreign_key "notification_permissions", "accounts", column: "from_account_id"
  add_foreign_key "notification_policies", "accounts", on_delete: :cascade
  add_foreign_key "notification_requests", "accounts", column: "from_account_id", on_delete: :cascade
  add_foreign_key "notification_requests", "accounts", on_delete: :cascade
  add_foreign_key "notification_requests", "statuses", column: "last_status_id", on_delete: :nullify
  add_foreign_key "notifications", "accounts", column: "from_account_id", name: "fk_fbd6b0bf9e", on_delete: :cascade
  add_foreign_key "notifications", "accounts", name: "fk_c141c8ee55", on_delete: :cascade
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id", name: "fk_34d54b0a33", on_delete: :cascade
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id", name: "fk_63b044929b", on_delete: :cascade
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id", name: "fk_f5fc4c1ee3", on_delete: :cascade
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id", name: "fk_e84df68546", on_delete: :cascade
  add_foreign_key "oauth_applications", "users", column: "owner_id", name: "fk_b0988c7c0a", on_delete: :cascade
  add_foreign_key "one_time_keys", "devices", on_delete: :cascade
  add_foreign_key "poll_votes", "accounts", on_delete: :cascade
  add_foreign_key "poll_votes", "polls", on_delete: :cascade
  add_foreign_key "polls", "accounts", on_delete: :cascade
  add_foreign_key "polls", "statuses", on_delete: :cascade
  add_foreign_key "preview_card_trends", "preview_cards", on_delete: :cascade
  add_foreign_key "preview_cards", "accounts", column: "author_account_id", on_delete: :nullify
  add_foreign_key "report_notes", "accounts", on_delete: :cascade
  add_foreign_key "report_notes", "reports", on_delete: :cascade
  add_foreign_key "reports", "accounts", column: "action_taken_by_account_id", name: "fk_bca45b75fd", on_delete: :nullify
  add_foreign_key "reports", "accounts", column: "assigned_account_id", on_delete: :nullify
  add_foreign_key "reports", "accounts", column: "target_account_id", name: "fk_eb37af34f0", on_delete: :cascade
  add_foreign_key "reports", "accounts", name: "fk_4b81f7522c", on_delete: :cascade
  add_foreign_key "scheduled_statuses", "accounts", on_delete: :cascade
  add_foreign_key "session_activations", "oauth_access_tokens", column: "access_token_id", name: "fk_957e5bda89", on_delete: :cascade
  add_foreign_key "session_activations", "users", name: "fk_e5fda67334", on_delete: :cascade
  add_foreign_key "severed_relationships", "accounts", column: "local_account_id", on_delete: :cascade
  add_foreign_key "severed_relationships", "accounts", column: "remote_account_id", on_delete: :cascade
  add_foreign_key "severed_relationships", "relationship_severance_events", on_delete: :cascade
  add_foreign_key "status_edits", "accounts", on_delete: :nullify
  add_foreign_key "status_edits", "statuses", on_delete: :cascade
  add_foreign_key "status_pins", "accounts", name: "fk_d4cb435b62", on_delete: :cascade
  add_foreign_key "status_pins", "statuses", on_delete: :cascade
  add_foreign_key "status_stats", "statuses", on_delete: :cascade
  add_foreign_key "status_trends", "accounts", on_delete: :cascade
  add_foreign_key "status_trends", "statuses", on_delete: :cascade
  add_foreign_key "statuses", "accounts", column: "in_reply_to_account_id", name: "fk_c7fa917661", on_delete: :nullify
  add_foreign_key "statuses", "accounts", name: "fk_9bda1543f7", on_delete: :cascade
  add_foreign_key "statuses", "statuses", column: "in_reply_to_id", on_delete: :nullify
  add_foreign_key "statuses", "statuses", column: "reblog_of_id", on_delete: :cascade
  add_foreign_key "statuses_tags", "statuses", on_delete: :cascade
  add_foreign_key "statuses_tags", "tags", name: "fk_3081861e21", on_delete: :cascade
  add_foreign_key "tag_follows", "accounts", on_delete: :cascade
  add_foreign_key "tag_follows", "tags", on_delete: :cascade
  add_foreign_key "tombstones", "accounts", on_delete: :cascade
  add_foreign_key "user_invite_requests", "users", on_delete: :cascade
  add_foreign_key "users", "accounts", name: "fk_50500f500d", on_delete: :cascade
  add_foreign_key "users", "invites", on_delete: :nullify
  add_foreign_key "users", "oauth_applications", column: "created_by_application_id", on_delete: :nullify
  add_foreign_key "users", "user_roles", column: "role_id", on_delete: :nullify
  add_foreign_key "web_push_subscriptions", "oauth_access_tokens", column: "access_token_id", on_delete: :cascade
  add_foreign_key "web_push_subscriptions", "users", on_delete: :cascade
  add_foreign_key "web_settings", "users", name: "fk_11910667b2", on_delete: :cascade
  add_foreign_key "webauthn_credentials", "users"

  create_view "instances", materialized: true, sql_definition: <<-SQL
      WITH domain_counts(domain, accounts_count) AS (
           SELECT accounts.domain,
              count(*) AS accounts_count
             FROM accounts
            WHERE (accounts.domain IS NOT NULL)
            GROUP BY accounts.domain
          )
   SELECT domain_counts.domain,
      domain_counts.accounts_count
     FROM domain_counts
  UNION
   SELECT domain_blocks.domain,
      COALESCE(domain_counts.accounts_count, (0)::bigint) AS accounts_count
     FROM (domain_blocks
       LEFT JOIN domain_counts ON (((domain_counts.domain)::text = (domain_blocks.domain)::text)))
  UNION
   SELECT domain_allows.domain,
      COALESCE(domain_counts.accounts_count, (0)::bigint) AS accounts_count
     FROM (domain_allows
       LEFT JOIN domain_counts ON (((domain_counts.domain)::text = (domain_allows.domain)::text)));
  SQL
  add_index "instances", "reverse(('.'::text || (domain)::text)), domain", name: "index_instances_on_reverse_domain"
  add_index "instances", ["domain"], name: "index_instances_on_domain", unique: true

  create_view "user_ips", sql_definition: <<-SQL
      SELECT t0.user_id,
      t0.ip,
      max(t0.used_at) AS used_at
     FROM ( SELECT users.id AS user_id,
              users.sign_up_ip AS ip,
              users.created_at AS used_at
             FROM users
            WHERE (users.sign_up_ip IS NOT NULL)
          UNION ALL
           SELECT session_activations.user_id,
              session_activations.ip,
              session_activations.updated_at
             FROM session_activations
          UNION ALL
           SELECT login_activities.user_id,
              login_activities.ip,
              login_activities.created_at
             FROM login_activities
            WHERE (login_activities.success = true)) t0
    GROUP BY t0.user_id, t0.ip;
  SQL
  create_view "account_summaries", materialized: true, sql_definition: <<-SQL
      SELECT accounts.id AS account_id,
      mode() WITHIN GROUP (ORDER BY t0.language) AS language,
      mode() WITHIN GROUP (ORDER BY t0.sensitive) AS sensitive
     FROM (accounts
       CROSS JOIN LATERAL ( SELECT statuses.account_id,
              statuses.language,
              statuses.sensitive
             FROM statuses
            WHERE ((statuses.account_id = accounts.id) AND (statuses.deleted_at IS NULL) AND (statuses.reblog_of_id IS NULL))
            ORDER BY statuses.id DESC
           LIMIT 20) t0)
    WHERE ((accounts.suspended_at IS NULL) AND (accounts.silenced_at IS NULL) AND (accounts.moved_to_account_id IS NULL) AND (accounts.discoverable = true) AND (accounts.locked = false))
    GROUP BY accounts.id;
  SQL
  add_index "account_summaries", ["account_id", "language", "sensitive"], name: "idx_on_account_id_language_sensitive_250461e1eb"
  add_index "account_summaries", ["account_id"], name: "index_account_summaries_on_account_id", unique: true

  create_view "global_follow_recommendations", materialized: true, sql_definition: <<-SQL
      SELECT t0.account_id,
      sum(t0.rank) AS rank,
      array_agg(t0.reason) AS reason
     FROM ( SELECT account_summaries.account_id,
              ((count(follows.id))::numeric / (1.0 + (count(follows.id))::numeric)) AS rank,
              'most_followed'::text AS reason
             FROM ((follows
               JOIN account_summaries ON ((account_summaries.account_id = follows.target_account_id)))
               JOIN users ON ((users.account_id = follows.account_id)))
            WHERE ((users.current_sign_in_at >= (now() - 'P30D'::interval)) AND (account_summaries.sensitive = false) AND (NOT (EXISTS ( SELECT 1
                     FROM follow_recommendation_suppressions
                    WHERE (follow_recommendation_suppressions.account_id = follows.target_account_id)))))
            GROUP BY account_summaries.account_id
           HAVING (count(follows.id) >= 5)
          UNION ALL
           SELECT account_summaries.account_id,
              (sum((status_stats.reblogs_count + status_stats.favourites_count)) / (1.0 + sum((status_stats.reblogs_count + status_stats.favourites_count)))) AS rank,
              'most_interactions'::text AS reason
             FROM ((status_stats
               JOIN statuses ON ((statuses.id = status_stats.status_id)))
               JOIN account_summaries ON ((account_summaries.account_id = statuses.account_id)))
            WHERE ((statuses.id >= (((date_part('epoch'::text, (now() - 'P30D'::interval)) * (1000)::double precision))::bigint << 16)) AND (account_summaries.sensitive = false) AND (NOT (EXISTS ( SELECT 1
                     FROM follow_recommendation_suppressions
                    WHERE (follow_recommendation_suppressions.account_id = statuses.account_id)))))
            GROUP BY account_summaries.account_id
           HAVING (sum((status_stats.reblogs_count + status_stats.favourites_count)) >= (5)::numeric)) t0
    GROUP BY t0.account_id
    ORDER BY (sum(t0.rank)) DESC;
  SQL
  add_index "global_follow_recommendations", ["account_id"], name: "index_global_follow_recommendations_on_account_id", unique: true

end
