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

      This command can be used to find whether a known email address is blocked,
      and if so, which account it was attached to.
    LONG_DESC
    def find(email)
      accts = CanonicalEmailBlock.find_blocks(email).map(&:reference_account).map(&:acct).to_a
      if accts.empty?
        say("#{email} is not blocked", :yellow)
      else
        accts.each do |acct|
          say(acct, :white)
        end
      end
    end

    desc 'remove EMAIL', 'Remove a canonical e-mail block'
    long_desc <<-LONG_DESC
      When suspending a local user, a hash of a "canonical" version of their e-mail
      address is stored to prevent them from signing up again.

      This command allows removing a canonical email block.
    LONG_DESC
    def remove(email)
      blocks = CanonicalEmailBlock.find_blocks(email)
      if blocks.empty?
        say("#{email} is not blocked", :yellow)
      else
        blocks.destroy_all
        say("Removed canonical email block for #{email}", :green)
      end
    end

    private

    def color(processed, failed)
      if !processed.zero? && failed.zero?
        :green
      elsif failed.zero?
        :yellow
      else
        :red
      end
    end
  end
end
