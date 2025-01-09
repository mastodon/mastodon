# frozen_string_literal: true

require_relative 'base'

require_relative 'accounts'
require_relative 'cache'
require_relative 'canonical_email_blocks'
require_relative 'domains'
require_relative 'email_domain_blocks'
require_relative 'emoji'
require_relative 'federation'
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

    include Federation

    map %w(--version -v) => :version

    desc 'version', 'Show version'
    def version
      say(Mastodon::Version.to_s)
    end
  end
end
