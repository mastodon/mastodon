# frozen_string_literal: true

require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class StatusesCLI < Thor
    include ActionView::Helpers::NumberHelper

    def self.exit_on_failure?
      true
    end

    option :days, type: :numeric, default: 90
    desc 'remove', 'Remove unreferenced statuses'
    long_desc <<~LONG_DESC
      Remove statuses that are not referenced by local user activity, such as
      ones that came from relays, or belonging to users that were once followed
      by someone locally but no longer are.

      This is a computationally heavy procedure that creates extra database
      indicides before commencing, and removes them afterward.
    LONG_DESC
    def remove
      say('Creating temporary database indices...')

      ActiveRecord::Base.connection.add_index(:accounts, :id, name: :index_accounts_local, where: 'domain is null', algorithm: :concurrently) unless ActiveRecord::Base.connection.index_name_exists?(:accounts, :index_accounts_local)
      ActiveRecord::Base.connection.add_index(:status_pins, :status_id, name: :index_status_pins_status_id, algorithm: :concurrently) unless ActiveRecord::Base.connection.index_name_exists?(:status_pins, :index_status_pins_status_id)
      ActiveRecord::Base.connection.add_index(:media_attachments, :remote_url, name: :index_media_attachments_remote_url, where: 'remote_url is not null', algorithm: :concurrently) unless ActiveRecord::Base.connection.index_name_exists?(:media_attachments, :index_media_attachments_remote_url)

      max_id   = Mastodon::Snowflake.id_at(options[:days].days.ago)
      start_at = Time.now.to_f

      say('Beginning removal... This might take a while...')

      Status.remote
            .where('id < ?', max_id)
            .where(reblog_of_id: nil)                                                                                                                                                                                              # Skip reblogs
            .where(in_reply_to_id: nil)                                                                                                                                                                                            # Skip replies
            .where('id NOT IN (SELECT status_pins.status_id FROM status_pins WHERE statuses.id = status_id)')                                                                                                                      # Skip statuses that are pinned on profiles
            .where('id NOT IN (SELECT mentions.status_id FROM mentions WHERE statuses.id = mentions.status_id AND mentions.account_id IN (SELECT accounts.id FROM accounts WHERE domain IS NULL))')                                # Skip statuses that mention local accounts
            .where('id NOT IN (SELECT statuses1.in_reply_to_id FROM statuses AS statuses1 WHERE statuses.id = statuses1.in_reply_to_id)')                                                                                          # Skip statuses favourited by local accounts
            .where('id NOT IN (SELECT bookmarks.status_id FROM bookmarks WHERE statuses.id = bookmarks.status_id)') # Skip statuses bookmarked by local users
            .where('id NOT IN (SELECT statuses1.reblog_of_id FROM statuses AS statuses1 WHERE statuses.id = statuses1.reblog_of_id AND statuses1.account_id IN (SELECT accounts.id FROM accounts WHERE accounts.domain IS NULL))') # Skip statuses reblogged by local accounts
            .where('account_id NOT IN (SELECT follows.target_account_id FROM follows WHERE statuses.account_id = follows.target_account_id)')                                                                                      # Skip accounts followed by local accounts
            .in_batches
            .delete_all

      say('Beginning removal of now-orphaned media attachments to free up disk space...')

      Scheduler::MediaCleanupScheduler.new.perform

      say("Done after #{Time.now.to_f - start_at}s", :green)
    ensure
      say('Removing temporary database indices to restore write performance...')

      ActiveRecord::Base.connection.remove_index(:accounts, name: :index_accounts_local) if ActiveRecord::Base.connection.index_name_exists?(:accounts, :index_accounts_local)
      ActiveRecord::Base.connection.remove_index(:status_pins, name: :index_status_pins_status_id) if ActiveRecord::Base.connection.index_name_exists?(:status_pins, :index_status_pins_status_id)
      ActiveRecord::Base.connection.remove_index(:media_attachments, name: :index_media_attachments_remote_url) if ActiveRecord::Base.connection.index_name_exists?(:media_attachments, :index_media_attachments_remote_url)
    end
  end
end
