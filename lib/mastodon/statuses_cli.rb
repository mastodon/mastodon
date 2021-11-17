# frozen_string_literal: true

require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class StatusesCLI < Thor
    include CLIHelper
    include ActionView::Helpers::NumberHelper

    def self.exit_on_failure?
      true
    end

    option :days, type: :numeric, default: 90
    option :clean_followed, type: :boolean
    option :skip_media_remove, type: :boolean
    option :vacuum, type: :boolean, default: false, desc: 'Reduce the file size and update the statistics. This option locks the table for a long time, so run it offline'
    option :batch_size, type: :numeric, default: 1_000, aliases: [:b], desc: 'Number of records in each batch'
    desc 'remove', 'Remove unreferenced statuses'
    long_desc <<~LONG_DESC
      Remove statuses that are not referenced by local user activity, such as
      ones that came from relays, or belonging to users that were once followed
      by someone locally but no longer are.

      This is a computationally heavy procedure that creates extra database
      indices before commencing, and removes them afterward.
    LONG_DESC
    def remove
      if options[:batch_size] < 1
        say('Cannot run with this batch_size setting, must be at least 1', :red)
        exit(1)
      end

      say('Creating temporary database indices...')

      ActiveRecord::Base.connection.add_index(:accounts, :id, name: :index_accounts_local, where: 'domain is null', algorithm: :concurrently, if_not_exists: true)
      ActiveRecord::Base.connection.add_index(:status_pins, :status_id, name: :index_status_pins_status_id, algorithm: :concurrently, if_not_exists: true)
      ActiveRecord::Base.connection.add_index(:media_attachments, :remote_url, name: :index_media_attachments_remote_url, where: 'remote_url is not null', algorithm: :concurrently, if_not_exists: true)

      max_id   = Mastodon::Snowflake.id_at(options[:days].days.ago)
      start_at = Time.now.to_f

      say('Extract the deletion target... This might take a while...')

      ActiveRecord::Base.connection.create_table('statuses_to_be_deleted', temporary: true)

      # Skip accounts followed by local accounts
      clean_followed_sql = 'AND NOT EXISTS (SELECT 1 FROM follows WHERE statuses.account_id = follows.target_account_id)' unless options[:clean_followed]

      ActiveRecord::Base.connection.exec_insert(<<-SQL.squish, 'SQL', [[nil, max_id]])
        INSERT INTO statuses_to_be_deleted (id)
        SELECT statuses.id FROM statuses WHERE deleted_at IS NULL AND NOT local AND uri IS NOT NULL AND (id < $1)
        AND NOT EXISTS (SELECT 1 FROM statuses AS statuses1 WHERE statuses.id = statuses1.in_reply_to_id)
        AND NOT EXISTS (SELECT 1 FROM statuses AS statuses1 WHERE statuses1.id = statuses.reblog_of_id AND (statuses1.uri IS NULL OR statuses1.local))
        AND NOT EXISTS (SELECT 1 FROM statuses AS statuses1 WHERE statuses.id = statuses1.reblog_of_id AND (statuses1.uri IS NULL OR statuses1.local OR statuses1.id >= $1))
        AND NOT EXISTS (SELECT 1 FROM status_pins WHERE statuses.id = status_id)
        AND NOT EXISTS (SELECT 1 FROM mentions WHERE statuses.id = mentions.status_id AND mentions.account_id IN (SELECT accounts.id FROM accounts WHERE domain IS NULL))
        AND NOT EXISTS (SELECT 1 FROM favourites WHERE statuses.id = favourites.status_id AND favourites.account_id IN (SELECT accounts.id FROM accounts WHERE domain IS NULL))
        AND NOT EXISTS (SELECT 1 FROM bookmarks WHERE statuses.id = bookmarks.status_id AND bookmarks.account_id IN (SELECT accounts.id FROM accounts WHERE domain IS NULL))
        #{clean_followed_sql}
      SQL

      say('Removing temporary database indices to restore write performance...')

      ActiveRecord::Base.connection.remove_index(:accounts, name: :index_accounts_local, if_exists: true)
      ActiveRecord::Base.connection.remove_index(:status_pins, name: :index_status_pins_status_id, if_exists: true)

      say('Beginning removal... This might take a while...')

      klass = Class.new(ActiveRecord::Base) do |c|
        c.table_name = 'statuses_to_be_deleted'
      end

      Object.const_set('StatusToBeDeleted', klass)

      scope     = StatusToBeDeleted
      processed = 0
      removed   = 0
      progress  = create_progress_bar(scope.count.fdiv(options[:batch_size]).ceil)

      scope.reorder(nil).in_batches(of: options[:batch_size]) do |relation|
        ids        = relation.pluck(:id)
        processed += ids.count
        removed   += Status.unscoped.where(id: ids).delete_all
        progress.increment
      end

      progress.stop

      if options[:vacuum]
        say('Run VACUUM and ANALYZE to statuses...')

        ActiveRecord::Base.connection.execute('VACUUM FULL ANALYZE statuses')
      else
        say('Run ANALYZE to statuses...')

        ActiveRecord::Base.connection.execute('ANALYZE statuses')
      end

      unless options[:skip_media_remove]
        say('Beginning removal of now-orphaned media attachments to free up disk space...')
        Scheduler::MediaCleanupScheduler.new.perform
      end

      say("Done after #{Time.now.to_f - start_at}s, removed #{removed} out of #{processed} statuses.", :green)
    ensure
      say('Removing temporary database indices to restore write performance...')

      ActiveRecord::Base.connection.remove_index(:accounts, name: :index_accounts_local, if_exists: true)
      ActiveRecord::Base.connection.remove_index(:status_pins, name: :index_status_pins_status_id, if_exists: true)
      ActiveRecord::Base.connection.remove_index(:media_attachments, name: :index_media_attachments_remote_url, if_exists: true)
    end
  end
end
