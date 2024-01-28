# frozen_string_literal: true

require_relative 'base'

module Mastodon::CLI
  class Cache < Base
    desc 'clear', 'Clear out the cache storage'
    def clear
      Rails.cache.clear
      say('OK', :green)
    end

    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :verbose, type: :boolean, aliases: [:v]
    desc 'recount TYPE', 'Update hard-cached counters'
    long_desc <<~LONG_DESC
      Update hard-cached counters of TYPE by counting referenced
      records from scratch. TYPE can be "accounts" or "statuses".

      It may take a very long time to finish, depending on the
      size of the database.
    LONG_DESC
    def recount(type)
      case type
      when 'accounts'
        processed, = parallelize_with_progress(accounts_with_stats) do |account|
          recount_account_stats(account)
        end
      when 'statuses'
        processed, = parallelize_with_progress(statuses_with_stats) do |status|
          recount_status_stats(status)
        end
      else
        fail_with_message "Unknown type: #{type}"
      end

      say
      say("OK, recounted #{processed} records", :green)
    end

    private

    def accounts_with_stats
      Account.local.includes(:account_stat)
    end

    def statuses_with_stats
      Status.includes(:status_stat)
    end

    def recount_account_stats(account)
      say "Recalculating account stats for `#{account.acct}`" if options[:verbose]
      account.account_stat.tap do |account_stat|
        account_stat.following_count = account.active_relationships.count
        account_stat.followers_count = account.passive_relationships.count
        account_stat.statuses_count  = account.statuses.where.not(visibility: :direct).count

        if account_stat.changed?
          say "Account stats for `#{account.acct}` changed and will be updated" if options[:verbose]
          account_stat.save
        end
      end
    end

    def recount_status_stats(status)
      say "Recalculating status stats for `#{status.id}`" if options[:verbose]
      status.status_stat.tap do |status_stat|
        status_stat.replies_count    = status.replies.where.not(visibility: :direct).count
        status_stat.reblogs_count    = status.reblogs.count
        status_stat.favourites_count = status.favourites.count

        if status_stat.changed?
          say "Status stats for `#{status.id}` changed and will be updated" if options[:verbose]
          status_stat.save
        end
      end
    end
  end
end
