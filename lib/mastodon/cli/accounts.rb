# frozen_string_literal: true

require 'set'
require_relative 'base'

module Mastodon::CLI
  class Accounts < Base
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
        scope     = Account.local.without_suspended
        progress  = create_progress_bar(scope.count)

        scope.find_in_batches do |accounts|
          accounts.each do |account|
            rotate_keys_for_account(account, delay)
            progress.increment
            processed += 1
          end

          delay += 5.minutes
        end

        progress.finish
        say("OK, rotated keys for #{processed} accounts", :green)
      elsif username.present?
        rotate_keys_for_account(Account.find_local(username))
        say('OK', :green)
      else
        fail_with_message 'No account(s) given'
      end
    end

    option :email, required: true
    option :confirmed, type: :boolean
    option :role
    option :reattach, type: :boolean
    option :force, type: :boolean
    option :approve, type: :boolean
    desc 'create USERNAME', 'Create a new user account'
    long_desc <<-LONG_DESC
      Create a new user account with a given USERNAME and an
      e-mail address provided with --email.

      With the --confirmed option, the confirmation e-mail will
      be skipped and the account will be active straight away.

      With the --role option, the role can be supplied.

      With the --reattach option, the new user will be reattached
      to a given existing username of an old account. If the old
      account is still in use by someone else, you can supply
      the --force option to delete the old record and reattach the
      username to the new account anyway.

      With the --approve option, the account will be approved.
    LONG_DESC
    def create(username)
      role_id  = nil

      if options[:role]
        role = UserRole.find_by(name: options[:role])

        fail_with_message 'Cannot find user role with that name' if role.nil?

        role_id = role.id
      end

      account  = Account.new(username: username)
      password = SecureRandom.hex
      user     = User.new(email: options[:email], password: password, agreement: true, role_id: role_id, confirmed_at: options[:confirmed] ? Time.now.utc : nil, bypass_invite_request_check: true)

      if options[:reattach]
        account = Account.find_local(username) || Account.new(username: username)

        if account.user.present? && !options[:force]
          say('The chosen username is currently in use', :red)
          say('Use --force to reattach it anyway and delete the other user')
          return
        elsif account.user.present?
          DeleteAccountService.new.call(account, reserve_email: false, reserve_username: false)
          account = Account.new(username: username)
        end
      end

      account.suspended_at = nil
      user.account         = account

      if user.save
        if options[:confirmed]
          user.confirmed_at = nil
          user.mark_email_as_confirmed!
        end

        user.approve! if options[:approve]

        say('OK', :green)
        say("New password: #{password}")
      else
        report_errors(user.errors)
      end
    end

    option :role
    option :remove_role, type: :boolean
    option :email
    option :confirm, type: :boolean
    option :enable, type: :boolean
    option :disable, type: :boolean
    option :disable_2fa, type: :boolean
    option :approve, type: :boolean
    option :reset_password, type: :boolean
    desc 'modify USERNAME', 'Modify a user account'
    long_desc <<-LONG_DESC
      Modify a user account.

      With the --role option, update the user's role. To remove the user's
      role, i.e. demote to normal user, use --remove-role.

      With the --email option, update the user's e-mail address. With
      the --confirm option, mark the user's e-mail as confirmed.

      With the --disable option, lock the user out of their account. The
      --enable option is the opposite.

      With the --approve option, the account will be approved, if it was
      previously not due to not having open registrations.

      With the --disable-2fa option, the two-factor authentication
      requirement for the user can be removed.

      With the --reset-password option, the user's password is replaced by
      a randomly-generated one, printed in the output.
    LONG_DESC
    def modify(username)
      user = Account.find_local(username)&.user

      fail_with_message 'No user with such username' if user.nil?

      if options[:role]
        role = UserRole.find_by(name: options[:role])

        fail_with_message 'Cannot find user role with that name' if role.nil?

        user.role_id = role.id
      elsif options[:remove_role]
        user.role_id = nil
      end

      password = SecureRandom.hex if options[:reset_password]
      user.password = password if options[:reset_password]
      user.email = options[:email] if options[:email]
      user.disabled = false if options[:enable]
      user.disabled = true if options[:disable]
      user.approved = true if options[:approve]
      user.otp_required_for_login = false if options[:disable_2fa]

      if user.save
        user.confirm if options[:confirm]

        say('OK', :green)
        say("New password: #{password}") if options[:reset_password]
      else
        report_errors(user.errors)
      end
    end

    option :email
    option :dry_run, type: :boolean
    desc 'delete [USERNAME]', 'Delete a user'
    long_desc <<-LONG_DESC
      Remove a user account with a given USERNAME.

      With the --email option, the user is selected based on email
      rather than username.
    LONG_DESC
    def delete(username = nil)
      if username.present? && options[:email].present?
        fail_with_message  'Use username or --email, not both'
      elsif username.blank? && options[:email].blank?
        fail_with_message 'No username provided'
      end

      account = nil

      if username.present?
        account = Account.find_local(username)
        fail_with_message 'No user with such username' if account.nil?
      else
        account = Account.left_joins(:user).find_by(user: { email: options[:email] })
        fail_with_message 'No user with such email' if account.nil?
      end

      say("Deleting user with #{account.statuses_count} statuses, this might take a while...#{dry_run_mode_suffix}")
      DeleteAccountService.new.call(account, reserve_email: false) unless dry_run?
      say("OK#{dry_run_mode_suffix}", :green)
    end

    option :force, type: :boolean, aliases: [:f], description: 'Override public key check'
    desc 'merge FROM TO', 'Merge two remote accounts into one'
    long_desc <<-LONG_DESC
      Merge two remote accounts specified by their username@domain
      into one, whereby the TO account is the one being merged into
      and kept, while the FROM one is removed. It is primarily meant
      to fix duplicates caused by other servers changing their domain.

      The command by default only works if both accounts have the same
      public key to prevent mistakes. To override this, use the --force.
    LONG_DESC
    def merge(from_acct, to_acct)
      username, domain = from_acct.split('@')
      from_account = Account.find_remote(username, domain)

      fail_with_message "No such account (#{from_acct})" if from_account.nil? || from_account.local?

      username, domain = to_acct.split('@')
      to_account = Account.find_remote(username, domain)

      fail_with_message "No such account (#{to_acct})" if to_account.nil? || to_account.local?

      if from_account.public_key != to_account.public_key && !options[:force]
        fail_with_message <<~ERROR
          Accounts don't have the same public key, might not be duplicates!
          Override with --force
        ERROR
      end

      to_account.merge_with!(from_account)
      from_account.destroy

      say('OK', :green)
    end

    desc 'fix-duplicates', 'Find duplicate remote accounts and merge them'
    option :dry_run, type: :boolean
    long_desc <<-LONG_DESC
      Merge known remote accounts sharing an ActivityPub actor identifier.

      Such duplicates can occur when a remote server admin misconfigures their
      domain configuration.
    LONG_DESC
    def fix_duplicates
      Account.remote.duplicate_uris.pluck(:uri).each do |uri|
        say("Duplicates found for #{uri}")
        begin
          ActivityPub::FetchRemoteAccountService.new.call(uri) unless dry_run?
        rescue => e
          say("Error processing #{uri}: #{e}", :red)
        end
      end
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

      fail_with_message 'No user with such username' if account.nil?

      backup = account.user.backups.create!
      BackupWorker.perform_async(backup.id)
      say('OK', :green)
    end

    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :dry_run, type: :boolean
    desc 'cull [DOMAIN...]', 'Remove remote accounts that no longer exist'
    long_desc <<-LONG_DESC
      Query every single remote account in the database to determine
      if it still exists on the origin server, and if it doesn't,
      remove it from the database.

      Accounts that have had confirmed activity within the last week
      are excluded from the checks.
    LONG_DESC
    def cull(*domains)
      skip_threshold = 7.days.ago
      skip_domains   = Concurrent::Set.new

      query = Account.remote.activitypub
      query = query.where(domain: domains) unless domains.empty?

      processed, culled = parallelize_with_progress(query.partitioned) do |account|
        next if account.updated_at >= skip_threshold || (account.last_webfingered_at.present? && account.last_webfingered_at >= skip_threshold) || skip_domains.include?(account.domain)

        code = 0

        begin
          code = Request.new(:head, account.uri).perform(&:code)
        rescue *Mastodon::HTTP_CONNECTION_ERRORS, Mastodon::PrivateNetworkAddressError
          skip_domains << account.domain
        end

        if [404, 410].include?(code)
          DeleteAccountService.new.call(account, reserve_username: false) unless dry_run?
          1
        else
          # Touch account even during dry run to avoid getting the account into the window again
          account.touch
        end
      end

      say("Visited #{processed} accounts, removed #{culled}#{dry_run_mode_suffix}", :green)

      unless skip_domains.empty?
        say('The following domains were not available during the check:', :yellow)
        skip_domains.each { |domain| say("    #{domain}") }
      end
    end

    option :all, type: :boolean
    option :domain
    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :verbose, type: :boolean, aliases: [:v]
    option :dry_run, type: :boolean
    desc 'refresh [USERNAMES]', 'Fetch remote user data and files'
    long_desc <<-LONG_DESC
      Fetch remote user data and files for one or multiple accounts.

      With the --all option, all remote accounts will be processed.
      Through the --domain option, this can be narrowed down to a
      specific domain only. Otherwise, remote accounts must be
      specified with space-separated USERNAMES.
    LONG_DESC
    def refresh(*usernames)
      if options[:domain] || options[:all]
        scope  = Account.remote
        scope  = scope.where(domain: options[:domain]) if options[:domain]

        processed, = parallelize_with_progress(scope) do |account|
          next if dry_run?

          account.reset_avatar!
          account.reset_header!
          account.save
        end

        say("Refreshed #{processed} accounts#{dry_run_mode_suffix}", :green, true)
      elsif !usernames.empty?
        usernames.each do |user|
          user, domain = user.split('@')
          account = Account.find_remote(user, domain)

          fail_with_message 'No such account' if account.nil?

          next if dry_run?

          begin
            account.reset_avatar!
            account.reset_header!
            account.save
          rescue Mastodon::UnexpectedResponseError
            say("Account failed: #{user}@#{domain}", :red)
          end
        end

        say("OK#{dry_run_mode_suffix}", :green)
      else
        fail_with_message 'No account(s) given'
      end
    end

    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :verbose, type: :boolean, aliases: [:v]
    desc 'follow USERNAME', 'Make all local accounts follow account specified by USERNAME'
    def follow(username)
      target_account = Account.find_local(username)

      fail_with_message 'No such account' if target_account.nil?

      processed, = parallelize_with_progress(Account.local.without_suspended) do |account|
        FollowService.new.call(account, target_account, bypass_limit: true)
      end

      say("OK, followed target from #{processed} accounts", :green)
    end

    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :verbose, type: :boolean, aliases: [:v]
    desc 'unfollow ACCT', 'Make all local accounts unfollow account specified by ACCT'
    def unfollow(acct)
      username, domain = acct.split('@')
      target_account = Account.find_remote(username, domain)

      fail_with_message 'No such account' if target_account.nil?

      processed, = parallelize_with_progress(target_account.followers.local) do |account|
        UnfollowService.new.call(account, target_account)
      end

      say("OK, unfollowed target from #{processed} accounts", :green)
    end

    option :follows, type: :boolean, default: false
    option :followers, type: :boolean, default: false
    desc 'reset-relationships USERNAME', 'Reset all follows and/or followers for a user'
    long_desc <<-LONG_DESC
      Reset all follows and/or followers for a user specified by USERNAME.

      With the --follows option, the command unfollows everyone that the account follows,
      and then re-follows the users that would be followed by a brand new account.

      With the --followers option, the command removes all followers of the account.
    LONG_DESC
    def reset_relationships(username)
      fail_with_message 'Please specify either --follows or --followers, or both' unless options[:follows] || options[:followers]

      account = Account.find_local(username)

      fail_with_message 'No such account' if account.nil?

      total     = 0
      total    += account.following.reorder(nil).count if options[:follows]
      total    += account.followers.reorder(nil).count if options[:followers]
      progress  = create_progress_bar(total)
      processed = 0

      if options[:follows]
        account.following.reorder(nil).find_each do |target_account|
          UnfollowService.new.call(account, target_account)
        rescue => e
          progress.log pastel.red("Error processing #{target_account.id}: #{e}")
        ensure
          progress.increment
          processed += 1
        end

        BootstrapTimelineWorker.perform_async(account.id)
      end

      if options[:followers]
        account.followers.reorder(nil).find_each do |target_account|
          UnfollowService.new.call(target_account, account)
        rescue => e
          progress.log pastel.red("Error processing #{target_account.id}: #{e}")
        ensure
          progress.increment
          processed += 1
        end
      end

      progress.finish
      say("Processed #{processed} relationships", :green, true)
    end

    option :number, type: :numeric, aliases: [:n]
    option :all, type: :boolean
    desc 'approve [USERNAME]', 'Approve pending accounts'
    long_desc <<~LONG_DESC
      When registrations require review from staff, approve pending accounts,
      either all of them with the --all option, or a specific number of them
      specified with the --number (-n) option, or only a single specific
      account identified by its username.
    LONG_DESC
    def approve(username = nil)
      fail_with_message 'Number must be positive' if options[:number]&.negative?

      if options[:all]
        User.pending.find_each(&:approve!)
        say('OK', :green)
      elsif options[:number]&.positive?
        User.pending.order(created_at: :asc).limit(options[:number]).each(&:approve!)
        say('OK', :green)
      elsif username.present?
        account = Account.find_local(username)

        fail_with_message 'No such account' if account.nil?

        account.user&.approve!
        say('OK', :green)
      end
    end

    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :dry_run, type: :boolean
    desc 'prune', 'Prune remote accounts that never interacted with local users'
    long_desc <<-LONG_DESC
      Prune remote account that
      - follows no local accounts
      - is not followed by any local accounts
      - has no statuses on local
      - has not been mentioned
      - has not been favourited local posts
      - not muted/blocked by us
    LONG_DESC
    def prune
      _, deleted = parallelize_with_progress(prunable_accounts) do |account|
        next if account.bot? || account.group?
        next if account.suspended?
        next if account.silenced?

        account.destroy unless dry_run?
        1
      end

      say("OK, pruned #{deleted} accounts#{dry_run_mode_suffix}", :green)
    end

    option :force, type: :boolean
    option :replay, type: :boolean
    option :target
    desc 'migrate USERNAME', 'Migrate a local user to another account'
    long_desc <<~LONG_DESC
      With --replay, replay the last migration of the specified account, in
      case some remote server may not have properly processed the associated
      `Move` activity.

      With --target, specify another account to migrate to.

      With --force, perform the migration even if the selected account
      redirects to a different account that the one specified.
    LONG_DESC
    def migrate(username)
      fail_with_message 'Use --replay or --target, not both' if options[:replay].present? && options[:target].present?

      fail_with_message 'Use either --replay or --target' if options[:replay].blank? && options[:target].blank?

      account = Account.find_local(username)

      fail_with_message "No such account: #{username}" if account.nil?

      migration = nil

      if options[:replay]
        migration = account.migrations.last
        fail_with_message 'The specified account has not performed any migration' if migration.nil?

        fail_with_message 'The specified account is not redirecting to its last migration target. Use --force if you want to replay the migration anyway' unless options[:force] || migration.target_account_id == account.moved_to_account_id
      end

      if options[:target]
        target_account = ResolveAccountService.new.call(options[:target])

        fail_with_message "The specified target account could not be found: #{options[:target]}" if target_account.nil?

        fail_with_message 'The specified account is redirecting to a different target account. Use --force if you want to change the migration target' unless options[:force] || account.moved_to_account_id.nil? || account.moved_to_account_id == target_account.id

        begin
          migration = account.migrations.create!(acct: target_account.acct)
        rescue ActiveRecord::RecordInvalid => e
          fail_with_message "Error: #{e.message}"
        end
      end

      MoveService.new.call(migration)

      say("OK, migrated #{account.acct} to #{migration.target_account.acct}", :green)
    end

    private

    def prunable_accounts
      Account
        .remote
        .non_automated
        .where.not(referencing_account(Mention, :account_id))
        .where.not(referencing_account(Favourite, :account_id))
        .where.not(referencing_account(Status, :account_id))
        .where.not(referencing_account(Follow, :account_id))
        .where.not(referencing_account(Follow, :target_account_id))
        .where.not(referencing_account(Block, :account_id))
        .where.not(referencing_account(Block, :target_account_id))
        .where.not(referencing_account(Mute, :target_account_id))
        .where.not(referencing_account(Report, :target_account_id))
        .where.not(referencing_account(FollowRequest, :account_id))
        .where.not(referencing_account(FollowRequest, :target_account_id))
    end

    def referencing_account(model, attribute)
      model
        .where(model.arel_table[attribute].eq Account.arel_table[:id])
        .select(1)
        .arel
        .exists
    end

    def report_errors(errors)
      message = errors.map do |error|
        <<~STRING
          Failure/Error: #{error.attribute}
              #{error.type}
        STRING
      end.join

      fail_with_message message
    end

    def rotate_keys_for_account(account, delay = 0)
      fail_with_message 'No such account' if account.nil?

      old_key = account.private_key
      new_key = OpenSSL::PKey::RSA.new(2048)
      account.update(private_key: new_key.to_pem, public_key: new_key.public_key.to_pem)
      ActivityPub::UpdateDistributionWorker.perform_in(delay, account.id, { 'sign_with' => old_key })
    end
  end
end
