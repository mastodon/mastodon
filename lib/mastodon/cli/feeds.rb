# frozen_string_literal: true

require_relative 'base'

module Mastodon::CLI
  class Feeds < Base
    include Redisable

    option :all, type: :boolean, default: false
    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :verbose, type: :boolean, aliases: [:v]
    option :dry_run, type: :boolean, default: false
    desc 'build [USERNAME]', 'Build home and list feeds for one or all users'
    long_desc <<-LONG_DESC
      Build home and list feeds that are stored in Redis from the database.

      With the --all option, all active users will be processed.
      Otherwise, a single user specified by USERNAME.
    LONG_DESC
    def build(username = nil)
      if options[:all] || username.nil?
        processed, = parallelize_with_progress(active_user_accounts) do |account|
          PrecomputeFeedService.new.call(account) unless dry_run?
        end

        say("Regenerated feeds for #{processed} accounts #{dry_run_mode_suffix}", :green, true)
      elsif username.present?
        account = Account.find_local(username)

        fail_with_message 'No such account' if account.nil?

        PrecomputeFeedService.new.call(account) unless dry_run?

        say("OK #{dry_run_mode_suffix}", :green, true)
      else
        fail_with_message 'No account(s) given'
      end
    end

    desc 'clear', 'Remove all home and list feeds from Redis'
    def clear
      keys = redis.keys('feed:*')
      redis.del(keys)
      say('OK', :green)
    end

    desc 'vacuum', 'Remove home feeds of inactive users from Redis'
    long_desc <<-LONG_DESC
      Running this task should not be needed in most cases, as Mastodon will
      automatically clean up feeds from inactive accounts every day.

      However, this task is more aggressive in order to clean up feeds that
      may have been missed because of bugs or database mishaps.
    LONG_DESC
    def vacuum
      say('Deleting home feeds for deleted local users…')
      Account.local.where.missing(:user).select(:id).in_batches do |accounts|
        FeedManager.instance.clean_feeds!(:home, accounts.ids)
      end

      say('Deleting home feeds for remote users…')
      Account.remote.select(:id).in_batches do |accounts|
        FeedManager.instance.clean_feeds!(:home, accounts.ids)
      end
    end

    private

    def active_user_accounts
      Account.joins(:user).merge(User.active)
    end
  end
end
