require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class IdsToBigints < ActiveRecord::Migration[5.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def migrate_columns(to_type)
    included_columns = [
      %i(account_domain_blocks account_id),
      %i(account_domain_blocks id),
      %i(accounts id),
      %i(blocks account_id),
      %i(blocks id),
      %i(blocks target_account_id),
      %i(conversation_mutes account_id),
      %i(conversation_mutes id),
      %i(domain_blocks id),
      %i(favourites account_id),
      %i(favourites id),
      %i(favourites status_id),
      %i(follow_requests account_id),
      %i(follow_requests id),
      %i(follow_requests target_account_id),
      %i(follows account_id),
      %i(follows id),
      %i(follows target_account_id),
      %i(imports account_id),
      %i(imports id),
      %i(media_attachments account_id),
      %i(media_attachments id),
      %i(mentions account_id),
      %i(mentions id),
      %i(mutes account_id),
      %i(mutes id),
      %i(mutes target_account_id),
      %i(notifications account_id),
      %i(notifications from_account_id),
      %i(notifications id),
      %i(oauth_access_grants application_id),
      %i(oauth_access_grants id),
      %i(oauth_access_grants resource_owner_id),
      %i(oauth_access_tokens application_id),
      %i(oauth_access_tokens id),
      %i(oauth_access_tokens resource_owner_id),
      %i(oauth_applications id),
      %i(oauth_applications owner_id),
      %i(reports account_id),
      %i(reports action_taken_by_account_id),
      %i(reports id),
      %i(reports target_account_id),
      %i(session_activations access_token_id),
      %i(session_activations user_id),
      %i(session_activations web_push_subscription_id),
      %i(settings id),
      %i(settings thing_id),
      %i(statuses account_id),
      %i(statuses application_id),
      %i(statuses in_reply_to_account_id),
      %i(stream_entries account_id),
      %i(stream_entries id),
      %i(subscriptions account_id),
      %i(subscriptions id),
      %i(tags id),
      %i(users account_id),
      %i(users id),
      %i(web_settings id),
      %i(web_settings user_id),
    ]
    included_columns << %i(deprecated_preview_cards id) if table_exists?(:deprecated_preview_cards)

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
