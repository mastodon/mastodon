# frozen_string_literal: true

require 'thor'
require_relative 'mastodon/media_cli'
require_relative 'mastodon/emoji_cli'

module Mastodon
  class CLI < Thor
    desc 'media SUBCOMMAND ...ARGS', 'manage media files'
    subcommand 'media', Mastodon::MediaCLI

    desc 'emoji SUBCOMMAND ...ARGS', 'manage custom emoji'
    subcommand 'emoji', Mastodon::EmojiCLI
  end
end
