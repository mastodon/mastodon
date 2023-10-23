# frozen_string_literal: true

require_relative 'base'

require_relative 'accounts'
require_relative 'cache'
require_relative 'canonical_email_blocks'
require_relative 'domains'
require_relative 'email_domain_blocks'
require_relative 'emoji'
require_relative 'feeds'
require_relative 'ip_blocks'
require_relative 'maintenance'
require_relative 'media'
require_relative 'preview_cards'
require_relative 'search'
require_relative 'settings'
require_relative 'statuses'
require_relative 'upgrade'

module Mastodon::CLI
  class Main < Base
    desc 'media SUBCOMMAND ...ARGS', 'Manage media files'
    subcommand 'media', Media

    desc 'emoji SUBCOMMAND ...ARGS', 'Manage custom emoji'
    subcommand 'emoji', Emoji

    desc 'accounts SUBCOMMAND ...ARGS', 'Manage accounts'
    subcommand 'accounts', Accounts

    desc 'feeds SUBCOMMAND ...ARGS', 'Manage feeds'
    subcommand 'feeds', Feeds

    desc 'search SUBCOMMAND ...ARGS', 'Manage the search engine'
    subcommand 'search', Search

    desc 'settings SUBCOMMAND ...ARGS', 'Manage dynamic settings'
    subcommand 'settings', Settings

    desc 'statuses SUBCOMMAND ...ARGS', 'Manage statuses'
    subcommand 'statuses', Statuses

    desc 'domains SUBCOMMAND ...ARGS', 'Manage account domains'
    subcommand 'domains', Domains

    desc 'preview_cards SUBCOMMAND ...ARGS', 'Manage preview cards'
    subcommand 'preview_cards', PreviewCards

    desc 'cache SUBCOMMAND ...ARGS', 'Manage cache'
    subcommand 'cache', Cache

    desc 'upgrade SUBCOMMAND ...ARGS', 'Various version upgrade utilities'
    subcommand 'upgrade', Upgrade

    desc 'email_domain_blocks SUBCOMMAND ...ARGS', 'Manage e-mail domain blocks'
    subcommand 'email_domain_blocks', EmailDomainBlocks

    desc 'ip_blocks SUBCOMMAND ...ARGS', 'Manage IP blocks'
    subcommand 'ip_blocks', IpBlocks

    desc 'canonical_email_blocks SUBCOMMAND ...ARGS', 'Manage canonical e-mail blocks'
    subcommand 'canonical_email_blocks', CanonicalEmailBlocks

    desc 'maintenance SUBCOMMAND ...ARGS', 'Various maintenance utilities'
    subcommand 'maintenance', Maintenance

    desc 'self-destruct', 'Erase the server from the federation'
    long_desc <<~LONG_DESC
      Erase the server from the federation by broadcasting account delete
      activities to all known other servers. This allows a "clean exit" from
      running a Mastodon server, as it leaves next to no cache behind on
      other servers.

      This command is always interactive and requires confirmation twice.

      No local data is actually deleted, because emptying the
      database or removing files is much faster through other, external
      means, such as e.g. deleting the entire VPS. However, because other
      servers will delete data about local users, but no local data will be
      updated (such as e.g. followers), there will be a state mismatch
      that will lead to glitches and issues if you then continue to run and use
      the server.

      So either you know exactly what you are doing, or you are starting
      from a blank slate afterwards by manually clearing out all the local
      data!
    LONG_DESC
    def self_destruct
      require 'tty-prompt'

      prompt = TTY::Prompt.new

      if SelfDestructHelper.self_destruct?
        prompt.ok('Self-destruct mode is already enabled for this Mastodon server')

        pending_accounts = Account.local.without_suspended.count + Account.local.suspended.joins(:deletion_request).count
        sidekiq_stats = Sidekiq::Stats.new

        if pending_accounts.positive?
          prompt.warn("#{pending_accounts} accounts are still pending deletion.")
        elsif sidekiq_stats.enqueued.positive?
          prompt.warn('Deletion notices are still being processed')
        elsif sidekiq_stats.retry_size.positive?
          prompt.warn('At least one delivery attempt for each deletion notice has been made, but some have failed and are scheduled for retry')
        else
          prompt.ok('Every deletion notice has been sent! You can safely delete all data and decomission your servers!')
        end

        exit(0)
      end

      exit(1) unless prompt.ask('Type in the domain of the server to confirm:', required: true) == Rails.configuration.x.local_domain

      prompt.warn('This operation WILL NOT be reversible.')
      prompt.warn('While the data won\'t be erased locally, the server will be in a BROKEN STATE afterwards.')
      prompt.warn('The deletion process itself may take a long time, and will be handled by Sidekiq, so do not shut it down until it has finished (you will be able to re-run this command to see the state of the self-destruct process).')

      exit(1) if prompt.no?('Are you sure you want to proceed?')

      self_destruct_value = Rails.application.message_verifier('self-destruct').generate(Rails.configuration.x.local_domain)
      prompt.ok('To switch Mastodon to self-destruct mode, add the following variable to your evironment (e.g. by adding a line to your `.env.production`) and restart all Mastodon processes:')
      prompt.ok("  SELF_DESTRUCT=#{self_destruct_value}")
      prompt.ok("\nYou can re-run this command to see the state of the self-destruct process.")
    rescue TTY::Reader::InputInterrupt
      exit(1)
    end

    map %w(--version -v) => :version

    desc 'version', 'Show version'
    def version
      say(Mastodon::Version.to_s)
    end
  end
end
