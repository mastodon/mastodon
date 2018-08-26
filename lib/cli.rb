# frozen_string_literal: true

require 'thor'
require_relative 'mastodon/media_cli'
require_relative 'mastodon/emoji_cli'
require_relative 'mastodon/accounts_cli'
module Mastodon
  class CLI < Thor
    desc 'media SUBCOMMAND ...ARGS', 'Manage media files'
    subcommand 'media', Mastodon::MediaCLI

    desc 'emoji SUBCOMMAND ...ARGS', 'Manage custom emoji'
    subcommand 'emoji', Mastodon::EmojiCLI

    desc 'accounts SUBCOMMAND ...ARGS', 'Manage accounts'
    subcommand 'accounts', Mastodon::AccountsCLI
  end
end
