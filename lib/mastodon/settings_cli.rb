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
      Setting.registrations_mode = 'open'
      say('OK', :green)
    end

    desc 'approved', 'Open approval-based registrations'
    option :require_reason, type: :boolean, aliases: [:require_invite_text]
    long_desc <<~LONG_DESC
      Set registrations to require review from staff.

      With --require-reason, require users to enter a reason when registering,
      otherwise this field is optional.
    LONG_DESC
    def approved
      Setting.registrations_mode = 'approved'
      Setting.require_invite_text = options[:require_reason] unless options[:require_reason].nil?
      say('OK', :green)
    end

    desc 'close', 'Close registrations'
    def close
      Setting.registrations_mode = 'none'
      say('OK', :green)
    end
  end

  class SettingsCLI < Thor
    desc 'registrations SUBCOMMAND ...ARGS', 'Manage state of registrations'
    subcommand 'registrations', RegistrationsCLI
  end
end
