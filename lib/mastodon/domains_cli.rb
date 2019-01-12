# frozen_string_literal: true

require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class DomainsCLI < Thor
    def self.exit_on_failure?
      true
    end

    option :dry_run, type: :boolean
    desc 'purge DOMAIN', 'Remove accounts from a DOMAIN without a trace'
    long_desc <<-LONG_DESC
      Remove all accounts from a given DOMAIN without leaving behind any
      records. Unlike a suspension, if the DOMAIN still exists in the wild,
      it means the accounts could return if they are resolved again.
    LONG_DESC
    def purge(domain)
      removed = 0
      dry_run = options[:dry_run] ? ' (DRY RUN)' : ''

      Account.where(domain: domain).find_each do |account|
        unless options[:dry_run]
          SuspendAccountService.new.call(account)
          account.destroy
        end

        removed += 1
        say('.', :green, false)
      end

      DomainBlock.where(domain: domain).destroy_all

      say
      say("Removed #{removed} accounts#{dry_run}", :green)
    end
  end
end
