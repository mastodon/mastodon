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
        exit(1)
      end
    end

    option :email, required: true
    option :confirmed, type: :boolean
    option :role, default: 'user'
    option :reattach, type: :boolean
    option :force, type: :boolean
    desc 'create USERNAME', 'Create a new user'
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
    def create(username)
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

      account.suspended = false
      user.account      = account

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

        exit(1)
      end
    end

    option :role
    option :email
    option :confirm, type: :boolean
    option :enable, type: :boolean
    option :disable, type: :boolean
    option :disable_2fa, type: :boolean
    desc 'modify USERNAME', 'Modify a user'
    long_desc <<-LONG_DESC
      Modify a user account.

      With the --role option, update the user's role to one of "user",
      "moderator" or "admin".

      With the --email option, update the user's e-mail address. With
      the --confirm option, mark the user's e-mail as confirmed.

      With the --disable option, lock the user out of their account. The
      --enable option is the opposite.

      With the --disable-2fa option, the two-factor authentication
      requirement for the user can be removed.
    LONG_DESC
    def modify(username)
      user = Account.find_local(username)&.user

      if user.nil?
        say('No user with such username', :red)
        exit(1)
      end

      if options[:role]
        user.admin = options[:role] == 'admin'
        user.moderator = options[:role] == 'moderator'
      end

      user.email = options[:email] if options[:email]
      user.disabled = false if options[:enable]
      user.disabled = true if options[:disable]
      user.otp_required_for_login = false if options[:disable_2fa]
      user.confirm if options[:confirm]

      if user.save
        say('OK', :green)
      else
        user.errors.to_h.each do |key, error|
          say('Failure/Error: ', :red)
          say(key)
          say('    ' + error, :red)
        end

        exit(1)
      end
    end

    desc 'delete USERNAME', 'Delete a user'
    long_desc <<-LONG_DESC
      Remove a user account with a given USERNAME.
    LONG_DESC
    def delete(username)
      account = Account.find_local(username)

      if account.nil?
        say('No user with such username', :red)
        exit(1)
      end

      say("Deleting user with #{account.statuses_count} statuses, this might take a while...")
      SuspendAccountService.new.call(account, remove_user: true)
      say('OK', :green)
    end

    desc 'backup USERNAME', 'Request a backup for a user'
    long_desc <<-LONG_DESC
      Request a new backup for an account with a given USERNAME.

      The backup will be created in Sidekiq asynchronously, and
      the user will receive an e-mail with a link to it once
      it's done.
    LONG_DESC
    def backup(username)
      account = Account.find_local(username)

      if account.nil?
        say('No user with such username', :red)
        exit(1)
      end

      backup = account.user.backups.create!
      BackupWorker.perform_async(backup.id)
      say('OK', :green)
    end

    option :dry_run, type: :boolean
    desc 'cull', 'Remove remote accounts that no longer exist'
    long_desc <<-LONG_DESC
      Query every single remote account in the database to determine
      if it still exists on the origin server, and if it doesn't,
      remove it from the database.

      Accounts that have had confirmed activity within the last week
      are excluded from the checks.

      If 10 or more accounts from the same domain cannot be queried
      due to a connection error (such as missing DNS records) then
      the domain is considered dead, and all other accounts from it
      are deleted without further querying.

      With the --dry-run option, no deletes will actually be carried
      out.
    LONG_DESC
    def cull
      domain_thresholds = Hash.new { |hash, key| hash[key] = 0 }
      skip_threshold    = 7.days.ago
      culled            = 0
      dead_servers      = []
      dry_run           = options[:dry_run] ? ' (DRY RUN)' : ''

      Account.remote.where(protocol: :activitypub).partitioned.find_each do |account|
        next if account.updated_at >= skip_threshold || account.last_webfingered_at >= skip_threshold

        unless dead_servers.include?(account.domain)
          begin
            code = Request.new(:head, account.uri).perform(&:code)
          rescue HTTP::ConnectionError
            domain_thresholds[account.domain] += 1

            if domain_thresholds[account.domain] >= 10
              dead_servers << account.domain
            end
          rescue StandardError
            next
          end
        end

        if [404, 410].include?(code) || dead_servers.include?(account.domain)
          unless options[:dry_run]
            SuspendAccountService.new.call(account)
            account.destroy
          end

          culled += 1
          say('.', :green, false)
        else
          say('.', nil, false)
        end
      end

      say
      say("Removed #{culled} accounts (#{dead_servers.size} dead servers)#{dry_run}", :green)

      unless dead_servers.empty?
        say('R.I.P.:', :yellow)
        dead_servers.each { |domain| say('    ' + domain) }
      end
    end

    option :all, type: :boolean
    option :domain
    desc 'refresh [USERNAME]', 'Fetch remote user data and files'
    long_desc <<-LONG_DESC
      Fetch remote user data and files for one or multiple accounts.

      With the --all option, all remote accounts will be processed.
      Through the --domain option, this can be narrowed down to a
      specific domain only. Otherwise, a single remote account must
      be specified with USERNAME.

      All processing is done in the background through Sidekiq.
    LONG_DESC
    def refresh(username = nil)
      if options[:domain] || options[:all]
        queued = 0
        scope  = Account.remote
        scope  = scope.where(domain: options[:domain]) if options[:domain]

        scope.select(:id).reorder(nil).find_in_batches do |accounts|
          Maintenance::RedownloadAccountMediaWorker.push_bulk(accounts.map(&:id))
          queued += accounts.size
        end

        say("Scheduled refreshment of #{queued} accounts", :green, true)
      elsif username.present?
        username, domain = username.split('@')
        account = Account.find_remote(username, domain)

        if account.nil?
          say('No such account', :red)
          exit(1)
        end

        Maintenance::RedownloadAccountMediaWorker.perform_async(account.id)
        say('OK', :green)
      else
        say('No account(s) given', :red)
        exit(1)
      end
    end

    private

    def rotate_keys_for_account(account, delay = 0)
      if account.nil?
        say('No such account', :red)
        exit(1)
      end

      old_key = account.private_key
      new_key = OpenSSL::PKey::RSA.new(2048).to_pem
      account.update(private_key: new_key)
      ActivityPub::UpdateDistributionWorker.perform_in(delay, account.id, sign_with: old_key)
    end
  end
end
