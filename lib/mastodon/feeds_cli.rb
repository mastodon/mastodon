# frozen_string_literal: true

require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class FeedsCLI < Thor
    option :all, type: :boolean, default: false
    option :background, type: :boolean, default: false
    option :dry_run, type: :boolean, default: false
    option :verbose, type: :boolean, default: false
    desc 'build [USERNAME]', 'Build home and list feeds for one or all users'
    long_desc <<-LONG_DESC
      Build home and list feeds that are stored in Redis from the database.

      With the --all option, all active users will be processed.
      Otherwise, a single user specified by USERNAME.

      With the --background option, regeneration will be queued into Sidekiq,
      and the command will exit as soon as possible.

      With the --dry-run option, no work will be done.

      With the --verbose option, when accounts are processed sequentially in the
      foreground, the IDs of the accounts will be printed.
    LONG_DESC
    def build(username = nil)
      dry_run = options[:dry_run] ? '(DRY RUN)' : ''

      if options[:all] || username.nil?
        processed = 0
        queued    = 0

        User.active.select(:id, :account_id).reorder(nil).find_in_batches do |users|
          if options[:background]
            RegenerationWorker.push_bulk(users.map(&:account_id)) unless options[:dry_run]
            queued += users.size
          else
            users.each do |user|
              RegenerationWorker.new.perform(user.account_id) unless options[:dry_run]
              options[:verbose] ? say(user.account_id) : say('.', :green, false)
              processed += 1
            end
          end
        end

        if options[:background]
          say("Scheduled feed regeneration for #{queued} accounts #{dry_run}", :green, true)
        else
          say
          say("Regenerated feeds for #{processed} accounts #{dry_run}", :green, true)
        end
      elsif username.present?
        account = Account.find_local(username)

        if options[:background]
          RegenerationWorker.perform_async(account.id) unless options[:dry_run]
        else
          RegenerationWorker.new.perform(account.id) unless options[:dry_run]
        end

        say("OK #{dry_run}", :green, true)
      else
        say('No account(s) given', :red)
        exit(1)
      end
    end

    desc 'clear', 'Remove all home and list feeds from Redis'
    def clear
      keys = Redis.current.keys('feed:*')

      Redis.current.pipelined do
        keys.each { |key| Redis.current.del(key) }
      end

      say('OK', :green)
    end
  end
end
