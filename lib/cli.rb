# frozen_string_literal: true

require 'thor'
require_relative 'mastodon/media_cli'

module Mastodon
  class CLI < Thor
    desc 'media SUBCOMMAND ...ARGS', 'manage media files'
    subcommand 'media', Mastodon::MediaCLI
  end
end
