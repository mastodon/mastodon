# frozen_string_literal: true

require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class RegistrationsCLI < Thor
    def self.exit_on_failure?
      true
    end

    desc 'open', 'Open registrations'
    def open
      Setting.open_registrations = true
      say('OK', :green)
    end

    desc 'close', 'Close registrations'
    def close
      Setting.open_registrations = false
      say('OK', :green)
    end
  end

  class SettingsCLI < Thor
    desc 'registrations SUBCOMMAND ...ARGS', 'Manage state of registrations'
    subcommand 'registrations', RegistrationsCLI
  end
end
