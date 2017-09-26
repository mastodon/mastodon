require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class IdsToBigints < ActiveRecord::Migration[5.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  INCLUDED_COLUMNS = [
    [:account_domain_blocks, :account_id],
    [:account_domain_blocks, :id],
    [:accounts, :id],
    [:blocks, :account_id],
    [:blocks, :id],
    [:blocks, :target_account_id],
    [:conversation_mutes, :account_id],
    [:conversation_mutes, :id],
    [:domain_blocks, :id],
    [:favourites, :account_id],
    [:favourites, :id],
    [:favourites, :status_id],
    [:follow_requests, :account_id],
    [:follow_requests, :id],
    [:follow_requests, :target_account_id],
    [:follows, :account_id],
    [:follows, :id],
    [:follows, :target_account_id],
    [:imports, :account_id],
    [:imports, :id],
    [:media_attachments, :account_id],
    [:media_attachments, :id],
    [:mentions, :account_id],
    [:mentions, :id],
    [:mutes, :account_id],
    [:mutes, :id],
    [:mutes, :target_account_id],
    [:notifications, :account_id],
    [:notifications, :from_account_id],
    [:notifications, :id],
    [:oauth_access_grants, :application_id],
    [:oauth_access_grants, :id],
    [:oauth_access_grants, :resource_owner_id],
    [:oauth_access_tokens, :application_id],
    [:oauth_access_tokens, :id],
    [:oauth_access_tokens, :resource_owner_id],
    [:oauth_applications, :id],
    [:oauth_applications, :owner_id],
    [:reports, :account_id],
    [:reports, :action_taken_by_account_id],
    [:reports, :id],
    [:reports, :target_account_id],
    [:session_activations, :access_token_id],
    [:session_activations, :user_id],
    [:session_activations, :web_push_subscription_id],
    [:settings, :id],
    [:settings, :thing_id],
    [:statuses, :account_id],
    [:statuses, :application_id],
    [:statuses, :in_reply_to_account_id],
    [:stream_entries, :account_id],
    [:stream_entries, :id],
    [:subscriptions, :account_id],
    [:subscriptions, :id],
    [:tags, :id],
    [:users, :account_id],
    [:users, :id],
    [:web_settings, :id],
    [:web_settings, :user_id],
  ]
  INCLUDED_COLUMNS << [:deprecated_preview_cards, :id] if table_exists?(:deprecated_preview_cards)

  def up
    INCLUDED_COLUMNS.each do |column_parts|
      table, column = column_parts

      change_column_type_concurrently table, column, :bigint
      cleanup_concurrent_column_type_change table, column
    end
  end

  def down
    INCLUDED_COLUMNS.each do |column_parts|
      table, column = column_parts

      change_column_type_concurrently table, column, :integer
      cleanup_concurrent_column_type_change table, column
    end
  end
end
