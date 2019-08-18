# frozen_string_literal: true

require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class CacheCLI < Thor
    def self.exit_on_failure?
      true
    end

    desc 'clear', 'Clear out the cache storage'
    def clear
      Rails.cache.clear
      say('OK', :green)
    end

    desc 'recount TYPE', 'Update hard-cached counters'
    long_desc <<~LONG_DESC
      Update hard-cached counters of TYPE by counting referenced
      records from scratch. TYPE can be "accounts" or "statuses".

      It may take a very long time to finish, depending on the
      size of the database.
    LONG_DESC
    def recount(type)
      processed = 0

      case type
      when 'accounts'
        Account.local.includes(:account_stat).find_each do |account|
          account_stat                 = account.account_stat
          account_stat.following_count = account.active_relationships.count
          account_stat.followers_count = account.passive_relationships.count
          account_stat.statuses_count  = account.statuses.where.not(visibility: :direct).count

          account_stat.save if account_stat.changed?

          processed += 1
          say('.', :green, false)
        end
      when 'statuses'
        Status.includes(:status_stat).find_each do |status|
          status_stat                  = status.status_stat
          status_stat.replies_count    = status.replies.where.not(visibility: :direct).count
          status_stat.reblogs_count    = status.reblogs.count
          status_stat.favourites_count = status.favourites.count

          status_stat.save if status_stat.changed?

          processed += 1
          say('.', :green, false)
        end
      else
        say("Unknown type: #{type}", :red)
        exit(1)
      end

      say
      say("OK, recounted #{processed} records", :green)
    end
  end
end
