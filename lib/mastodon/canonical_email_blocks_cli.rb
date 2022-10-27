# frozen_string_literal: true

require 'concurrent'
require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class CanonicalEmailBlocksCLI < Thor
    include CLIHelper

    def self.exit_on_failure?
      true
    end

    desc 'find EMAIL', 'Find a given e-mail address in the canonical e-mail blocks'
    long_desc <<-LONG_DESC
      When suspending a local user, a hash of a "canonical" version of their e-mail
      address is stored to prevent them from signing up again.

      This command can be used to find whether a known email address is blocked.
    LONG_DESC
    def find(email)
      accts = CanonicalEmailBlock.matching_email(email)

      if accts.empty?
        say("#{email} is not blocked", :green)
      else
        say("#{email} is blocked", :red)
      end
    end

    desc 'remove EMAIL', 'Remove a canonical e-mail block'
    long_desc <<-LONG_DESC
      When suspending a local user, a hash of a "canonical" version of their e-mail
      address is stored to prevent them from signing up again.

      This command allows removing a canonical email block.
    LONG_DESC
    def remove(email)
      blocks = CanonicalEmailBlock.matching_email(email)

      if blocks.empty?
        say("#{email} is not blocked", :green)
      else
        blocks.destroy_all
        say("Unblocked #{email}", :green)
      end
    end
  end
end
