# frozen_string_literal: true

require 'rubygems/package'
require_relative '../../config/boot'
require_relative '../../config/environment'
require_relative 'cli_helper'

module Mastodon
  class AccountsCLI < Thor
    option :all, type: :boolean
    desc 'rotate [USERNAME]', 'Generate and broadcast new keys'
    long_desc <<-LONG_DESC
      Generate and broadcast new RSA keys as part of security
      maintenance.

      With the --all option, all local accounts will be subject
      to the rotation. Otherwise, and by default, only a single
      account specified by the USERNAME argument will be
      processed.
    LONG_DESC
    def rotate(username = nil)
      if options[:all]
        processed = 0

        Account.local.find_each do |account|
          rotate_keys_for_account(account)
          processed += 1
          say('.', :green, false)
        end

        say
        say("OK, rotated keys for #{processed} accounts", :green)
      elsif username.present?
        rotate_keys_for_account(Account.find_local(username))
        say('OK', :green)
      else
        say('No account(s) given', :red)
      end
    end

    private

    def rotate_keys_for_account(account)
      old_key = account.private_key
      new_key = OpenSSL::PKey::RSA.new(2048).to_pem
      account.update(private_key: new_key)
      ActivityPub::UpdateDistributionWorker.perform_async(account.id, sign_with: old_key)
    end
  end
end
