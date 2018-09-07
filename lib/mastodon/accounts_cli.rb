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
        delay     = 0

        Account.local.without_suspended.find_in_batches do |accounts|
          accounts.each do |account|
            rotate_keys_for_account(account, delay)
            processed += 1
            say('.', :green, false)
          end

          delay += 5.minutes
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

    option :email, required: true
    option :confirmed, type: :boolean
    option :role, default: 'user'
    option :reattach, type: :boolean
    option :force, type: :boolean
    desc 'add USERNAME', 'Create a new user'
    long_desc <<-LONG_DESC
      Create a new user account with a given USERNAME and an
      e-mail address provided with --email.

      With the --confirmed option, the confirmation e-mail will
      be skipped and the account will be active straight away.

      With the --role option one of  "user", "admin" or "moderator"
      can be supplied. Defaults to "user"

      With the --reattach option, the new user will be reattached
      to a given existing username of an old account. If the old
      account is still in use by someone else, you can supply
      the --force option to delete the old record and reattach the
      username to the new account anyway.
    LONG_DESC
    def add(username)
      account  = Account.new(username: username)
      password = SecureRandom.hex
      user     = User.new(email: options[:email], password: password, admin: options[:role] == 'admin', moderator: options[:role] == 'moderator', confirmed_at: Time.now.utc)

      if options[:reattach]
        account = Account.find_local(username) || Account.new(username: username)

        if account.user.present? && !options[:force]
          say('The chosen username is currently in use', :red)
          say('Use --force to reattach it anyway and delete the other user')
          return
        elsif account.user.present?
          account.user.destroy!
        end
      end

      user.account = account

      if user.save
        if options[:confirmed]
          user.confirmed_at = nil
          user.confirm!
        end

        say('OK', :green)
        say("New password: #{password}")
      else
        user.errors.to_h.each do |key, error|
          say('Failure/Error: ', :red)
          say(key)
          say('    ' + error, :red)
        end
      end
    end

    desc 'del USERNAME', 'Delete a user'
    long_desc <<-LONG_DESC
      Remove a user account with a given USERNAME.
    LONG_DESC
    def del(username)
      account = Account.find_local(username)

      if account.nil?
        say('No user with such username', :red)
        return
      end

      say("Deleting user with #{account.statuses_count}, this might take a while...")
      SuspendAccountService.new.call(account, remove_user: true)
      say('OK', :green)
    end

    private

    def rotate_keys_for_account(account, delay = 0)
      old_key = account.private_key
      new_key = OpenSSL::PKey::RSA.new(2048).to_pem
      account.update(private_key: new_key)
      ActivityPub::UpdateDistributionWorker.perform_in(delay, account.id, sign_with: old_key)
    end
  end
end
