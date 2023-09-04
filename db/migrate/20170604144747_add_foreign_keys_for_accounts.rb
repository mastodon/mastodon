class AddForeignKeysForAccounts < ActiveRecord::Migration[5.1]
  def change
    add_foreign_key :statuses, :accounts, on_delete: :cascade
    add_foreign_key :statuses, :accounts, column: :in_reply_to_account_id, on_delete: :nullify
    add_foreign_key :statuses, :statuses, column: :in_reply_to_id, on_delete: :nullify
    add_foreign_key :account_domain_blocks, :accounts, on_delete: :cascade
    add_foreign_key :conversation_mutes, :accounts, on_delete: :cascade
    add_foreign_key :conversation_mutes, :conversations, on_delete: :cascade
    add_foreign_key :favourites, :accounts, on_delete: :cascade
    add_foreign_key :favourites, :statuses, on_delete: :cascade
    add_foreign_key :blocks, :accounts, on_delete: :cascade
    add_foreign_key :blocks, :accounts, column: :target_account_id, on_delete: :cascade
    add_foreign_key :follow_requests, :accounts, on_delete: :cascade
    add_foreign_key :follow_requests, :accounts, column: :target_account_id, on_delete: :cascade
    add_foreign_key :follows, :accounts, on_delete: :cascade
    add_foreign_key :follows, :accounts, column: :target_account_id, on_delete: :cascade
    add_foreign_key :mutes, :accounts, on_delete: :cascade
    add_foreign_key :mutes, :accounts, column: :target_account_id, on_delete: :cascade
    add_foreign_key :imports, :accounts, on_delete: :cascade
    add_foreign_key :media_attachments, :accounts, on_delete: :nullify
    add_foreign_key :media_attachments, :statuses, on_delete: :nullify
    add_foreign_key :mentions, :accounts, on_delete: :cascade
    add_foreign_key :mentions, :statuses, on_delete: :cascade
    add_foreign_key :notifications, :accounts, on_delete: :cascade
    add_foreign_key :notifications, :accounts, column: :from_account_id, on_delete: :cascade
    add_foreign_key :preview_cards, :statuses, on_delete: :cascade
    add_foreign_key :reports, :accounts, on_delete: :cascade
    add_foreign_key :reports, :accounts, column: :target_account_id, on_delete: :cascade
    add_foreign_key :reports, :accounts, column: :action_taken_by_account_id, on_delete: :nullify
    add_foreign_key :statuses_tags, :statuses, on_delete: :cascade
    add_foreign_key :statuses_tags, :tags, on_delete: :cascade
    add_foreign_key :stream_entries, :accounts, on_delete: :cascade
    add_foreign_key :subscriptions, :accounts, on_delete: :cascade
    add_foreign_key :users, :accounts, on_delete: :cascade
    add_foreign_key :web_settings, :users, on_delete: :cascade
    add_foreign_key :oauth_access_grants, :users, column: :resource_owner_id, on_delete: :cascade
    add_foreign_key :oauth_access_grants, :oauth_applications, column: :application_id, on_delete: :cascade
    add_foreign_key :oauth_access_tokens, :users, column: :resource_owner_id, on_delete: :cascade
    add_foreign_key :oauth_access_tokens, :oauth_applications, column: :application_id, on_delete: :cascade
  end
end
