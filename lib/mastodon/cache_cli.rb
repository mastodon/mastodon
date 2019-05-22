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
  end
end
