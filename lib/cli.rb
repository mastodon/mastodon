# frozen_string_literal: true

require 'thor'
require_relative 'mastodon/media_cli'
require_relative 'mastodon/emoji_cli'
require_relative 'mastodon/accounts_cli'
require_relative 'mastodon/feeds_cli'
require_relative 'mastodon/search_cli'
require_relative 'mastodon/settings_cli'
require_relative 'mastodon/statuses_cli'
require_relative 'mastodon/domains_cli'
require_relative 'mastodon/preview_cards_cli'
require_relative 'mastodon/cache_cli'
require_relative 'mastodon/upgrade_cli'
require_relative 'mastodon/email_domain_blocks_cli'
require_relative 'mastodon/ip_blocks_cli'
require_relative 'mastodon/maintenance_cli'
require_relative 'mastodon/version'

module Mastodon
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc 'media SUBCOMMAND ...ARGS', 'Manage media files'
    subcommand 'media', Mastodon::MediaCLI

    desc 'emoji SUBCOMMAND ...ARGS', 'Manage custom emoji'
    subcommand 'emoji', Mastodon::EmojiCLI

    desc 'accounts SUBCOMMAND ...ARGS', 'Manage accounts'
    subcommand 'accounts', Mastodon::AccountsCLI

    desc 'feeds SUBCOMMAND ...ARGS', 'Manage feeds'
    subcommand 'feeds', Mastodon::FeedsCLI

    desc 'search SUBCOMMAND ...ARGS', 'Manage the search engine'
    subcommand 'search', Mastodon::SearchCLI

    desc 'settings SUBCOMMAND ...ARGS', 'Manage dynamic settings'
    subcommand 'settings', Mastodon::SettingsCLI

    desc 'statuses SUBCOMMAND ...ARGS', 'Manage statuses'
    subcommand 'statuses', Mastodon::StatusesCLI

    desc 'domains SUBCOMMAND ...ARGS', 'Manage account domains'
    subcommand 'domains', Mastodon::DomainsCLI

    desc 'preview_cards SUBCOMMAND ...ARGS', 'Manage preview cards'
    subcommand 'preview_cards', Mastodon::PreviewCardsCLI

    desc 'cache SUBCOMMAND ...ARGS', 'Manage cache'
    subcommand 'cache', Mastodon::CacheCLI

    desc 'upgrade SUBCOMMAND ...ARGS', 'Various version upgrade utilities'
    subcommand 'upgrade', Mastodon::UpgradeCLI

    desc 'email_domain_blocks SUBCOMMAND ...ARGS', 'Manage e-mail domain blocks'
    subcommand 'email_domain_blocks', Mastodon::EmailDomainBlocksCLI

    desc 'ip_blocks SUBCOMMAND ...ARGS', 'Manage IP blocks'
    subcommand 'ip_blocks', Mastodon::IpBlocksCLI

    desc 'maintenance SUBCOMMAND ...ARGS', 'Various maintenance utilities'
    subcommand 'maintenance', Mastodon::MaintenanceCLI

    option :dry_run, type: :boolean
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

      exit(1) unless prompt.ask('Type in the domain of the server to confirm:', required: true) == Rails.configuration.x.local_domain

      prompt.warn('This operation WILL NOT be reversible. It can also take a long time.')
      prompt.warn('While the data won\'t be erased locally, the server will be in a BROKEN STATE afterwards.')
      prompt.warn('A running Sidekiq process is required. Do not shut it down until queues clear.')

      exit(1) if prompt.no?('Are you sure you want to proceed?')

      inboxes   = Account.inboxes
      processed = 0
      dry_run   = options[:dry_run] ? ' (DRY RUN)' : ''

      Setting.registrations_mode = 'none' unless options[:dry_run]

      if inboxes.empty?
        Account.local.without_suspended.in_batches.update_all(suspended_at: Time.now.utc, suspension_origin: :local) unless options[:dry_run]
        prompt.ok('It seems like your server has not federated with anything')
        prompt.ok('You can shut it down and delete it any time')
        return
      end

      prompt.warn('Do NOT interrupt this process...')

      delete_account = ->(account) do
        payload = ActiveModelSerializers::SerializableResource.new(
          account,
          serializer: ActivityPub::DeleteActorSerializer,
          adapter: ActivityPub::Adapter
        ).as_json

        json = Oj.dump(ActivityPub::LinkedDataSignature.new(payload).sign!(account))

        unless options[:dry_run]
          ActivityPub::DeliveryWorker.push_bulk(inboxes) do |inbox_url|
            [json, account.id, inbox_url]
          end

          account.suspend!(block_email: false)
        end

        processed += 1
      end

      Account.local.without_suspended.find_each { |account| delete_account.call(account) }
      Account.local.suspended.joins(:deletion_request).find_each { |account| delete_account.call(account) }

      prompt.ok("Queued #{inboxes.size * processed} items into Sidekiq for #{processed} accounts#{dry_run}")
      prompt.ok('Wait until Sidekiq processes all items, then you can shut everything down and delete the data')
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
