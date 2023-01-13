require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class IdsToBigints < ActiveRecord::Migration[5.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def migrate_columns(to_type)
    included_columns = [
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
    included_columns << [:deprecated_preview_cards, :id] if table_exists?(:deprecated_preview_cards)

    # Print out a warning that this will probably take a while.
    if $stdout.isatty
      say ''
      say 'WARNING: This migration may take a *long* time for large instances'
      say 'It will *not* lock tables for any significant time, but it may run'
      say 'for a very long time. We will pause for 10 seconds to allow you to'
      say 'interrupt this migration if you are not ready.'
      say ''
      say 'This migration has some sections that can be safely interrupted'
      say 'and restarted later, and will tell you when those are occurring.'
      say ''
      say 'For more information, see https://github.com/mastodon/mastodon/pull/5088'

      10.downto(1) do |i|
        say "Continuing in #{i} second#{i == 1 ? '' : 's'}...", true
        sleep 1
      end
    end

    tables = included_columns.map(&:first).uniq
    table_sizes = {}

    # Sort tables by their size
    tables.each do |table|
      table_sizes[table] = estimate_rows_in_table(table)
    end

    ordered_columns = included_columns.sort_by do |col_parts|
      [-table_sizes[col_parts.first], col_parts.last]
    end

    ordered_columns.each do |column_parts|
      table, column = column_parts

      # Skip this if we're resuming and already did this one.
      next if column_for(table, column).sql_type == to_type.to_s

      change_column_type_concurrently table, column, to_type
      cleanup_concurrent_column_type_change table, column
    end
  end

  def up
    migrate_columns(:bigint)
  end

  def down
    migrate_columns(:integer)
  end
end
