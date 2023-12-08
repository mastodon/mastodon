# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

describe Mastodon::CLI::Accounts do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

  it_behaves_like 'CLI Command'

  # `parallelize_with_progress` cannot run in transactions, so instead,
  # stub it with an alternative implementation that runs sequentially
  # and can run in transactions.
  def stub_parallelize_with_progress!
    allow(cli).to receive(:parallelize_with_progress) do |scope, &block|
      aggregate = 0
      total = 0

      scope.reorder(nil).find_each do |record|
        value = block.call(record)
        aggregate += value if value.is_a?(Integer)
        total += 1
      end

      [total, aggregate]
    end
  end

  describe '#create' do
    let(:action) { :create }

    shared_examples 'a new user with given email address and username' do
      it 'creates a new user with the specified email address' do
        subject

        expect(User.find_by(email: options[:email])).to be_present
      end

      it 'creates a new local account with the specified username' do
        subject

        expect(Account.find_local('tootctl_username')).to be_present
      end

      it 'returns "OK" and newly generated password' do
        allow(SecureRandom).to receive(:hex).and_return('test_password')

        expect { subject }
          .to output_results("OK\nNew password: test_password")
      end
    end

    context 'when required USERNAME and --email are provided' do
      let(:arguments) { ['tootctl_username'] }

      context 'with USERNAME and --email only' do
        let(:options) { { email: 'tootctl@example.com' } }

        it_behaves_like 'a new user with given email address and username'

        context 'with invalid --email value' do
          let(:options) { { email: 'invalid' } }

          it 'exits with an error message' do
            expect { subject }
              .to output_results('Failure/Error: email')
              .and raise_error(SystemExit)
          end
        end
      end

      context 'with --confirmed option' do
        let(:options) { { email: 'tootctl@example.com', confirmed: true } }

        it_behaves_like 'a new user with given email address and username'

        it 'creates a new user with confirmed status' do
          subject

          user = User.find_by(email: options[:email])

          expect(user.confirmed?).to be(true)
        end
      end

      context 'with --approve option' do
        let(:options) { { email: 'tootctl@example.com', approve: true } }

        before do
          Form::AdminSettings.new(registrations_mode: 'approved').save
        end

        it_behaves_like 'a new user with given email address and username'

        it 'creates a new user with approved status' do
          subject

          user = User.find_by(email: options[:email])

          expect(user.approved?).to be(true)
        end
      end

      context 'with --role option' do
        context 'when role exists' do
          let(:default_role) { Fabricate(:user_role) }
          let(:options) { { email: 'tootctl@example.com', role: default_role.name } }

          it_behaves_like 'a new user with given email address and username'

          it 'creates a new user and assigns the specified role' do
            subject

            role = User.find_by(email: options[:email])&.role

            expect(role.name).to eq(default_role.name)
          end
        end

        context 'when role does not exist' do
          let(:options) { { email: 'tootctl@example.com', role: '404' } }

          it 'exits with an error message indicating the role name was not found' do
            expect { subject }
              .to output_results('Cannot find user role with that name')
              .and raise_error(SystemExit)
          end
        end
      end

      context 'with --reattach option' do
        context "when account's user is present" do
          let(:options) { { email: 'tootctl_new@example.com', reattach: true } }
          let(:user) { Fabricate.build(:user, email: 'tootctl@example.com') }

          before do
            Fabricate(:account, username: 'tootctl_username', user: user)
          end

          it 'returns an error message indicating the username is already taken' do
            expect { subject }
              .to output_results("The chosen username is currently in use\nUse --force to reattach it anyway and delete the other user")
          end

          context 'with --force option' do
            let(:options) { { email: 'tootctl_new@example.com', reattach: true, force: true } }

            it 'reattaches the account to the new user and deletes the previous user' do
              subject

              user = Account.find_local('tootctl_username')&.user

              expect(user.email).to eq(options[:email])
            end
          end
        end

        context "when account's user is not present" do
          let(:options) { { email: 'tootctl@example.com', reattach: true } }

          before do
            Fabricate(:account, username: 'tootctl_username', user: nil)
          end

          it_behaves_like 'a new user with given email address and username'
        end
      end
    end

    context 'when required --email option is not provided' do
      let(:arguments) { ['tootctl_username'] }

      it 'raises a required argument missing error (Thor::RequiredArgumentMissingError)' do
        expect { subject }
          .to raise_error(Thor::RequiredArgumentMissingError)
      end
    end
  end

  describe '#modify' do
    let(:action) { :modify }

    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'exits with an error message indicating the user was not found' do
        expect { subject }
          .to output_results('No user with such username')
          .and raise_error(SystemExit)
      end
    end

    context 'when the given username is found' do
      let(:user) { Fabricate(:user) }
      let(:arguments) { [user.account.username] }

      context 'when no option is provided' do
        it 'returns a successful message' do
          expect { subject }
            .to output_results('OK')
        end

        it 'does not modify the user' do
          subject

          expect(user).to eq(user.reload)
        end
      end

      context 'with --role option' do
        context 'when the given role is not found' do
          let(:options) { { role: '404' } }

          it 'exits with an error message indicating the role was not found' do
            expect { subject }
              .to output_results('Cannot find user role with that name')
              .and raise_error(SystemExit)
          end
        end

        context 'when the given role is found' do
          let(:default_role) { Fabricate(:user_role) }
          let(:options) { { role: default_role.name } }

          it "updates the user's role to the specified role" do
            subject

            role = user.reload.role

            expect(role.name).to eq(default_role.name)
          end
        end
      end

      context 'with --remove-role option' do
        let(:options) { { remove_role: true } }
        let(:role) { Fabricate(:user_role) }
        let(:user) { Fabricate(:user, role: role) }

        it "removes the user's role successfully" do
          subject

          role = user.reload.role

          expect(role.name).to be_empty
        end
      end

      context 'with --email option' do
        let(:user) { Fabricate(:user, email: 'old_email@email.com') }
        let(:options) { { email: 'new_email@email.com' } }

        it "sets the user's unconfirmed email to the provided email address" do
          subject

          expect(user.reload.unconfirmed_email).to eq(options[:email])
        end

        it "does not update the user's original email address" do
          subject

          expect(user.reload.email).to eq('old_email@email.com')
        end

        context 'with --confirm option' do
          let(:user) { Fabricate(:user, email: 'old_email@email.com', confirmed_at: nil) }
          let(:options) { { email: 'new_email@email.com', confirm: true } }

          it "updates the user's email address to the provided email" do
            subject

            expect(user.reload.email).to eq(options[:email])
          end

          it "sets the user's email address as confirmed" do
            subject

            expect(user.reload.confirmed?).to be(true)
          end
        end
      end

      context 'with --confirm option' do
        let(:user) { Fabricate(:user, confirmed_at: nil) }
        let(:options) { { confirm: true } }

        it "confirms the user's email address" do
          subject

          expect(user.reload.confirmed?).to be(true)
        end
      end

      context 'with --approve option' do
        let(:user) { Fabricate(:user, approved: false) }
        let(:options) { { approve: true } }

        before do
          Form::AdminSettings.new(registrations_mode: 'approved').save
        end

        it 'approves the user' do
          expect { subject }.to change { user.reload.approved }.from(false).to(true)
        end
      end

      context 'with --disable option' do
        let(:user) { Fabricate(:user, disabled: false) }
        let(:options) { { disable: true } }

        it 'disables the user' do
          expect { subject }.to change { user.reload.disabled }.from(false).to(true)
        end
      end

      context 'with --enable option' do
        let(:user) { Fabricate(:user, disabled: true) }
        let(:options) { { enable: true } }

        it 'enables the user' do
          expect { subject }.to change { user.reload.disabled }.from(true).to(false)
        end
      end

      context 'with --reset-password option' do
        let(:options) { { reset_password: true } }

        it 'returns a new password for the user' do
          allow(SecureRandom).to receive(:hex).and_return('new_password')

          expect { subject }
            .to output_results('new_password')
        end
      end

      context 'with --disable-2fa option' do
        let(:user) { Fabricate(:user, otp_required_for_login: true) }
        let(:options) { { disable_2fa: true } }

        it 'disables the two-factor authentication for the user' do
          expect { subject }.to change { user.reload.otp_required_for_login }.from(true).to(false)
        end
      end

      context 'when provided data is invalid' do
        let(:user) { Fabricate(:user) }
        let(:options) { { email: 'invalid' } }

        it 'exits with an error message' do
          expect { subject }
            .to output_results('Failure/Error: email')
            .and raise_error(SystemExit)
        end
      end
    end
  end

  describe '#delete' do
    let(:action) { :delete }
    let(:account) { Fabricate(:account) }
    let(:delete_account_service) { instance_double(DeleteAccountService) }

    before do
      allow(DeleteAccountService).to receive(:new).and_return(delete_account_service)
      allow(delete_account_service).to receive(:call)
    end

    context 'when both username and --email are provided' do
      let(:arguments) { [account.username] }
      let(:options) { { email: account.user.email } }

      it 'exits with an error message indicating that only one should be used' do
        expect { subject }
          .to output_results('Use username or --email, not both')
          .and raise_error(SystemExit)
      end
    end

    context 'when neither username nor --email are provided' do
      it 'exits with an error message indicating that no username was provided' do
        expect { subject }
          .to output_results('No username provided')
          .and raise_error(SystemExit)
      end
    end

    context 'when username is provided' do
      let(:arguments) { [account.username] }

      it 'deletes the specified user successfully' do
        subject

        expect(delete_account_service).to have_received(:call).with(account, reserve_email: false).once
      end

      context 'with --dry-run option' do
        let(:options) { { dry_run: true } }

        it 'does not delete the specified user' do
          subject

          expect(delete_account_service).to_not have_received(:call).with(account, reserve_email: false)
        end

        it 'outputs a successful message in dry run mode' do
          expect { subject }
            .to output_results('OK (DRY RUN)')
        end
      end

      context 'when the given username is not found' do
        let(:arguments) { ['non_existent_username'] }

        it 'exits with an error message indicating that no user was found' do
          expect { subject }
            .to output_results('No user with such username')
            .and raise_error(SystemExit)
        end
      end
    end

    context 'when --email is provided' do
      let(:options) { { email: account.user.email } }

      it 'deletes the specified user successfully' do
        subject

        expect(delete_account_service).to have_received(:call).with(account, reserve_email: false).once
      end

      context 'with --dry-run option' do
        let(:options) { { email: account.user.email, dry_run: true } }

        it 'does not delete the user' do
          subject

          expect(delete_account_service).to_not have_received(:call).with(account, reserve_email: false)
        end

        it 'outputs a successful message in dry run mode' do
          expect { subject }
            .to output_results('OK (DRY RUN)')
        end
      end

      context 'when the given email address is not found' do
        let(:options) { { email: '404@example.com' } }

        it 'exits with an error message indicating that no user was found' do
          expect { subject }
            .to output_results('No user with such email')
            .and raise_error(SystemExit)
        end
      end
    end
  end

  describe '#approve' do
    let(:action) { :approve }
    let(:total_users) { 4 }

    before do
      Form::AdminSettings.new(registrations_mode: 'approved').save
      Fabricate.times(total_users, :user)
    end

    context 'with --all option' do
      let(:options) { { all: true } }

      it 'approves all pending registrations' do
        subject

        expect(User.pluck(:approved).all?(true)).to be(true)
      end
    end

    context 'with --number option' do
      context 'when the number is positive' do
        let(:options) { { number: 2 } }

        it 'approves the earliest n pending registrations' do
          subject

          n_earliest_pending_registrations = User.order(created_at: :asc).first(options[:number])

          expect(n_earliest_pending_registrations.all?(&:approved?)).to be(true)
        end

        it 'does not approve the remaining pending registrations' do
          subject

          pending_registrations = User.order(created_at: :asc).last(total_users - options[:number])

          expect(pending_registrations.all?(&:approved?)).to be(false)
        end
      end

      context 'when the number is negative' do
        let(:options) { { number: -1 } }

        it 'exits with an error message indicating that the number must be positive' do
          expect { subject }
            .to output_results('Number must be positive')
            .and raise_error(SystemExit)
        end
      end

      context 'when the given number is greater than the number of users' do
        let(:options) { { number: total_users * 2 } }

        it 'approves all users' do
          subject

          expect(User.pluck(:approved).all?(true)).to be(true)
        end

        it 'does not raise any error' do
          expect { subject }
            .to_not raise_error
        end
      end
    end

    context 'with username argument' do
      context 'when the given username is found' do
        let(:user) { User.last }
        let(:arguments) { [user.account.username] }

        it 'approves the specified user successfully' do
          subject

          expect(user.reload.approved?).to be(true)
        end
      end

      context 'when the given username is not found' do
        let(:arguments) { ['non_existent_username'] }

        it 'exits with an error message indicating that no such account was found' do
          expect { subject }
            .to output_results('No such account')
            .and raise_error(SystemExit)
        end
      end
    end
  end

  describe '#follow' do
    let(:action) { :follow }

    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'exits with an error message indicating that no account with the given username was found' do
        expect { subject }
          .to output_results('No such account')
          .and raise_error(SystemExit)
      end
    end

    context 'when the given username is found' do
      let!(:target_account)   { Fabricate(:account) }
      let!(:follower_bob)     { Fabricate(:account, username: 'bob') }
      let!(:follower_rony)    { Fabricate(:account, username: 'rony') }
      let!(:follower_charles) { Fabricate(:account, username: 'charles') }
      let(:follow_service)    { instance_double(FollowService, call: nil) }
      let(:arguments) { [target_account.username] }

      before do
        allow(FollowService).to receive(:new).and_return(follow_service)
        stub_parallelize_with_progress!
      end

      it 'makes all local accounts follow the target account' do
        subject

        expect(follow_service).to have_received(:call).with(follower_bob, target_account, any_args).once
        expect(follow_service).to have_received(:call).with(follower_rony, target_account, any_args).once
        expect(follow_service).to have_received(:call).with(follower_charles, target_account, any_args).once
      end

      it 'displays a successful message' do
        expect { subject }
          .to output_results("OK, followed target from #{Account.local.count} accounts")
      end
    end
  end

  describe '#unfollow' do
    let(:action) { :unfollow }

    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'exits with an error message indicating that no account with the given username was found' do
        expect { subject }
          .to output_results('No such account')
          .and raise_error(SystemExit)
      end
    end

    context 'when the given username is found' do
      let!(:target_account)  { Fabricate(:account) }
      let!(:follower_chris)  { Fabricate(:account, username: 'chris', domain: nil) }
      let!(:follower_rambo)  { Fabricate(:account, username: 'rambo', domain: nil) }
      let!(:follower_ana)    { Fabricate(:account, username: 'ana', domain: nil) }
      let(:unfollow_service) { instance_double(UnfollowService, call: nil) }
      let(:arguments) { [target_account.username] }

      before do
        accounts = [follower_chris, follower_rambo, follower_ana]
        accounts.each { |account| account.follow!(target_account) }
        allow(UnfollowService).to receive(:new).and_return(unfollow_service)
        stub_parallelize_with_progress!
      end

      it 'makes all local accounts unfollow the target account' do
        subject

        expect(unfollow_service).to have_received(:call).with(follower_chris, target_account).once
        expect(unfollow_service).to have_received(:call).with(follower_rambo, target_account).once
        expect(unfollow_service).to have_received(:call).with(follower_ana, target_account).once
      end

      it 'displays a successful message' do
        expect { subject }
          .to output_results('OK, unfollowed target from 3 accounts')
      end
    end
  end

  describe '#backup' do
    let(:action) { :backup }

    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'exits with an error message indicating that there is no such account' do
        expect { subject }
          .to output_results('No user with such username')
          .and raise_error(SystemExit)
      end
    end

    context 'when the given username is found' do
      let(:account) { Fabricate(:account) }
      let(:user) { account.user }
      let(:arguments) { [account.username] }

      it 'creates a new backup for the specified user' do
        expect { subject }.to change { user.backups.count }.by(1)
      end

      it 'creates a backup job' do
        allow(BackupWorker).to receive(:perform_async)

        subject
        latest_backup = user.backups.last

        expect(BackupWorker).to have_received(:perform_async).with(latest_backup.id).once
      end

      it 'displays a successful message' do
        expect { subject }
          .to output_results('OK')
      end
    end
  end

  describe '#refresh' do
    context 'with --all option' do
      let!(:local_account)              { Fabricate(:account, domain: nil) }
      let!(:remote_account_example_com) { Fabricate(:account, domain: 'example.com') }
      let!(:account_example_net)        { Fabricate(:account, domain: 'example.net') }
      let(:scope)                       { Account.remote }

      before do
        # TODO: we should be using `stub_parallelize_with_progress!` but
        # this makes the assertions harder to write
        allow(cli).to receive(:parallelize_with_progress).and_yield(remote_account_example_com)
                                                         .and_yield(account_example_net)
                                                         .and_return([2, nil])
        cli.options = { all: true }
      end

      it 'refreshes the avatar for all remote accounts' do
        allow(remote_account_example_com).to receive(:reset_avatar!)
        allow(account_example_net).to receive(:reset_avatar!)

        cli.refresh

        expect(cli).to have_received(:parallelize_with_progress).with(scope).once
        expect(remote_account_example_com).to have_received(:reset_avatar!).once
        expect(account_example_net).to have_received(:reset_avatar!).once
      end

      it 'does not refresh avatar for local accounts' do
        allow(local_account).to receive(:reset_avatar!)

        cli.refresh

        expect(cli).to have_received(:parallelize_with_progress).with(scope).once
        expect(local_account).to_not have_received(:reset_avatar!)
      end

      it 'refreshes the header for all remote accounts' do
        allow(remote_account_example_com).to receive(:reset_header!)
        allow(account_example_net).to receive(:reset_header!)

        cli.refresh

        expect(cli).to have_received(:parallelize_with_progress).with(scope).once
        expect(remote_account_example_com).to have_received(:reset_header!).once
        expect(account_example_net).to have_received(:reset_header!).once
      end

      it 'does not refresh the header for local accounts' do
        allow(local_account).to receive(:reset_header!)

        cli.refresh

        expect(cli).to have_received(:parallelize_with_progress).with(scope).once
        expect(local_account).to_not have_received(:reset_header!)
      end

      it 'displays a successful message' do
        expect { cli.refresh }
          .to output_results('Refreshed 2 accounts')
      end

      context 'with --dry-run option' do
        before do
          cli.options = { all: true, dry_run: true }
        end

        it 'does not refresh the avatar for any account' do
          allow(local_account).to receive(:reset_avatar!)
          allow(remote_account_example_com).to receive(:reset_avatar!)
          allow(account_example_net).to receive(:reset_avatar!)

          cli.refresh

          expect(cli).to have_received(:parallelize_with_progress).with(scope).once
          expect(local_account).to_not have_received(:reset_avatar!)
          expect(remote_account_example_com).to_not have_received(:reset_avatar!)
          expect(account_example_net).to_not have_received(:reset_avatar!)
        end

        it 'does not refresh the header for any account' do
          allow(local_account).to receive(:reset_header!)
          allow(remote_account_example_com).to receive(:reset_header!)
          allow(account_example_net).to receive(:reset_header!)

          cli.refresh

          expect(cli).to have_received(:parallelize_with_progress).with(scope).once
          expect(local_account).to_not have_received(:reset_header!)
          expect(remote_account_example_com).to_not have_received(:reset_header!)
          expect(account_example_net).to_not have_received(:reset_header!)
        end

        it 'displays a successful message with (DRY RUN)' do
          expect { cli.refresh }
            .to output_results('Refreshed 2 accounts (DRY RUN)')
        end
      end
    end

    context 'with a list of accts' do
      let!(:account_example_com_a) { Fabricate(:account, domain: 'example.com') }
      let!(:account_example_com_b) { Fabricate(:account, domain: 'example.com') }
      let!(:account_example_net)   { Fabricate(:account, domain: 'example.net') }
      let(:arguments)              { [account_example_com_a.acct, account_example_com_b.acct] }

      before do
        # NOTE: `Account.find_remote` is stubbed so that `Account#reset_avatar!`
        # can be stubbed on the individual accounts.
        allow(Account).to receive(:find_remote).with(account_example_com_a.username, account_example_com_a.domain).and_return(account_example_com_a)
        allow(Account).to receive(:find_remote).with(account_example_com_b.username, account_example_com_b.domain).and_return(account_example_com_b)
        allow(Account).to receive(:find_remote).with(account_example_net.username, account_example_net.domain).and_return(account_example_net)
      end

      it 'resets the avatar for the specified accounts' do
        allow(account_example_com_a).to receive(:reset_avatar!)
        allow(account_example_com_b).to receive(:reset_avatar!)

        cli.refresh(*arguments)

        expect(account_example_com_a).to have_received(:reset_avatar!).once
        expect(account_example_com_b).to have_received(:reset_avatar!).once
      end

      it 'does not reset the avatar for unspecified accounts' do
        allow(account_example_net).to receive(:reset_avatar!)

        cli.refresh(*arguments)

        expect(account_example_net).to_not have_received(:reset_avatar!)
      end

      it 'resets the header for the specified accounts' do
        allow(account_example_com_a).to receive(:reset_header!)
        allow(account_example_com_b).to receive(:reset_header!)

        cli.refresh(*arguments)

        expect(account_example_com_a).to have_received(:reset_header!).once
        expect(account_example_com_b).to have_received(:reset_header!).once
      end

      it 'does not reset the header for unspecified accounts' do
        allow(account_example_net).to receive(:reset_header!)

        cli.refresh(*arguments)

        expect(account_example_net).to_not have_received(:reset_header!)
      end

      context 'when an UnexpectedResponseError is raised' do
        it 'displays a failure message' do
          allow(account_example_com_a).to receive(:reset_avatar!).and_raise(Mastodon::UnexpectedResponseError)

          expect { cli.refresh(*arguments) }
            .to output_results("Account failed: #{account_example_com_a.username}@#{account_example_com_a.domain}")
        end
      end

      context 'when a specified account is not found' do
        it 'exits with an error message' do
          allow(Account).to receive(:find_remote).with(account_example_com_b.username, account_example_com_b.domain).and_return(nil)

          expect { cli.refresh(*arguments) }
            .to output_results('No such account')
            .and raise_error(SystemExit)
        end
      end

      context 'with --dry-run option' do
        before do
          cli.options = { dry_run: true }
        end

        it 'does not refresh the avatar for any account' do
          allow(account_example_com_a).to receive(:reset_avatar!)
          allow(account_example_com_b).to receive(:reset_avatar!)

          cli.refresh(*arguments)

          expect(account_example_com_a).to_not have_received(:reset_avatar!)
          expect(account_example_com_b).to_not have_received(:reset_avatar!)
        end

        it 'does not refresh the header for any account' do
          allow(account_example_com_a).to receive(:reset_header!)
          allow(account_example_com_b).to receive(:reset_header!)

          cli.refresh(*arguments)

          expect(account_example_com_a).to_not have_received(:reset_header!)
          expect(account_example_com_b).to_not have_received(:reset_header!)
        end
      end
    end

    context 'with --domain option' do
      let!(:account_example_com_a) { Fabricate(:account, domain: 'example.com') }
      let!(:account_example_com_b) { Fabricate(:account, domain: 'example.com') }
      let!(:account_example_net)   { Fabricate(:account, domain: 'example.net') }
      let(:domain)                 { 'example.com' }
      let(:scope)                  { Account.remote.where(domain: domain) }

      before do
        allow(cli).to receive(:parallelize_with_progress).and_yield(account_example_com_a)
                                                         .and_yield(account_example_com_b)
                                                         .and_return([2, nil])
        cli.options = { domain: domain }
      end

      it 'refreshes the avatar for all accounts on specified domain' do
        allow(account_example_com_a).to receive(:reset_avatar!)
        allow(account_example_com_b).to receive(:reset_avatar!)

        cli.refresh

        expect(cli).to have_received(:parallelize_with_progress).with(scope).once
        expect(account_example_com_a).to have_received(:reset_avatar!).once
        expect(account_example_com_b).to have_received(:reset_avatar!).once
      end

      it 'does not refresh the avatar for accounts outside specified domain' do
        allow(account_example_net).to receive(:reset_avatar!)

        cli.refresh

        expect(cli).to have_received(:parallelize_with_progress).with(scope).once
        expect(account_example_net).to_not have_received(:reset_avatar!)
      end

      it 'refreshes the header for all accounts on specified domain' do
        allow(account_example_com_a).to receive(:reset_header!)
        allow(account_example_com_b).to receive(:reset_header!)

        cli.refresh

        expect(cli).to have_received(:parallelize_with_progress).with(scope)
        expect(account_example_com_a).to have_received(:reset_header!).once
        expect(account_example_com_b).to have_received(:reset_header!).once
      end

      it 'does not refresh the header for accounts outside specified domain' do
        allow(account_example_net).to receive(:reset_header!)

        cli.refresh

        expect(cli).to have_received(:parallelize_with_progress).with(scope).once
        expect(account_example_net).to_not have_received(:reset_header!)
      end
    end

    context 'when neither a list of accts nor options are provided' do
      it 'exits with an error message' do
        expect { cli.refresh }
          .to output_results('No account(s) given')
          .and raise_error(SystemExit)
      end
    end
  end

  describe '#rotate' do
    let(:action) { :rotate }

    context 'when neither username nor --all option are given' do
      it 'exits with an error message' do
        expect { subject }
          .to output_results('No account(s) given')
          .and raise_error(SystemExit)
      end
    end

    context 'when a username is given' do
      let(:account) { Fabricate(:account) }
      let(:arguments) { [account.username] }

      it 'correctly rotates keys for the specified account' do
        old_private_key = account.private_key
        old_public_key = account.public_key

        subject
        account.reload

        expect(account.private_key).to_not eq(old_private_key)
        expect(account.public_key).to_not eq(old_public_key)
      end

      it 'broadcasts the new keys for the specified account' do
        allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_in)

        subject

        expect(ActivityPub::UpdateDistributionWorker).to have_received(:perform_in).with(anything, account.id, anything).once
      end

      context 'when the given username is not found' do
        let(:arguments) { ['non_existent_username'] }

        it 'exits with an error message when the specified username is not found' do
          expect { subject }
            .to output_results('No such account')
            .and raise_error(SystemExit)
        end
      end
    end

    context 'when --all option is provided' do
      let!(:accounts) { Fabricate.times(2, :account) }
      let(:options) { { all: true } }

      it 'correctly rotates keys for all local accounts' do
        old_private_keys = accounts.map(&:private_key)
        old_public_keys = accounts.map(&:public_key)

        subject
        accounts.each(&:reload)

        expect(accounts.map(&:private_key)).to_not eq(old_private_keys)
        expect(accounts.map(&:public_key)).to_not eq(old_public_keys)
      end

      it 'broadcasts the new keys for each account' do
        allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_in)

        subject

        accounts.each do |account|
          expect(ActivityPub::UpdateDistributionWorker).to have_received(:perform_in).with(anything, account.id, anything).once
        end
      end
    end
  end

  describe '#merge' do
    let(:action) { :merge }

    shared_examples 'an account not found' do |acct|
      it 'exits with an error message indicating that there is no such account' do
        expect { subject }
          .to output_results("No such account (#{acct})")
          .and raise_error(SystemExit)
      end
    end

    context 'when "from_account" is not found' do
      let(:to_account) { Fabricate(:account, domain: 'example.com') }
      let(:arguments)  { ['non_existent_username@domain.com', "#{to_account.username}@#{to_account.domain}"] }

      it_behaves_like 'an account not found', 'non_existent_username@domain.com'
    end

    context 'when "from_account" is a local account' do
      let(:from_account) { Fabricate(:account, domain: nil, username: 'bob') }
      let(:to_account)   { Fabricate(:account, domain: 'example.com') }
      let(:arguments)    { [from_account.username, "#{to_account.username}@#{to_account.domain}"] }

      it_behaves_like 'an account not found', 'bob'
    end

    context 'when "to_account" is not found' do
      let(:from_account) { Fabricate(:account, domain: 'example.com') }
      let(:arguments)    { ["#{from_account.username}@#{from_account.domain}", 'non_existent_username'] }

      it_behaves_like 'an account not found', 'non_existent_username'
    end

    context 'when "to_account" is local' do
      let(:from_account) { Fabricate(:account, domain: 'example.com') }
      let(:to_account)   { Fabricate(:account, domain: nil, username: 'bob') }
      let(:arguments) do
        ["#{from_account.username}@#{from_account.domain}", "#{to_account.username}@#{to_account.domain}"]
      end

      it_behaves_like 'an account not found', 'bob@'
    end

    context 'when "from_account" and "to_account" public keys do not match' do
      let(:from_account) { instance_double(Account, username: 'bob', domain: 'example1.com', local?: false, public_key: 'from_account') }
      let(:to_account)   { instance_double(Account, username: 'bob', domain: 'example2.com', local?: false, public_key: 'to_account') }
      let(:arguments) do
        ["#{from_account.username}@#{from_account.domain}", "#{to_account.username}@#{to_account.domain}"]
      end

      before do
        allow(Account).to receive(:find_remote).with(from_account.username, from_account.domain).and_return(from_account)
        allow(Account).to receive(:find_remote).with(to_account.username, to_account.domain).and_return(to_account)
      end

      it 'exits with an error message indicating that the accounts do not have the same pub key' do
        expect { subject }
          .to output_results("Accounts don't have the same public key, might not be duplicates!\nOverride with --force")
          .and raise_error(SystemExit)
      end

      context 'with --force option' do
        let(:options) { { force: true } }

        before do
          allow(to_account).to receive(:merge_with!)
          allow(from_account).to receive(:destroy)
        end

        it 'merges "from_account" into "to_account"' do
          subject

          expect(to_account).to have_received(:merge_with!).with(from_account).once
        end

        it 'deletes "from_account"' do
          subject

          expect(from_account).to have_received(:destroy).once
        end
      end
    end

    context 'when "from_account" and "to_account" public keys match' do
      let(:from_account) { instance_double(Account, username: 'bob', domain: 'example1.com', local?: false, public_key: 'pub_key') }
      let(:to_account)   { instance_double(Account, username: 'bob', domain: 'example2.com', local?: false, public_key: 'pub_key') }
      let(:arguments) do
        ["#{from_account.username}@#{from_account.domain}", "#{to_account.username}@#{to_account.domain}"]
      end

      before do
        allow(Account).to receive(:find_remote).with(from_account.username, from_account.domain).and_return(from_account)
        allow(Account).to receive(:find_remote).with(to_account.username, to_account.domain).and_return(to_account)
        allow(to_account).to receive(:merge_with!)
        allow(from_account).to receive(:destroy)
      end

      it 'merges "from_account" into "to_account"' do
        subject

        expect(to_account).to have_received(:merge_with!).with(from_account).once
      end

      it 'deletes "from_account"' do
        subject

        expect(from_account).to have_received(:destroy)
      end
    end
  end

  describe '#cull' do
    let(:action) { :cull }
    let(:delete_account_service) { instance_double(DeleteAccountService, call: nil) }
    let!(:tom)   { Fabricate(:account, updated_at: 30.days.ago, username: 'tom', uri: 'https://example.com/users/tom', domain: 'example.com', protocol: :activitypub) }
    let!(:bob)   { Fabricate(:account, updated_at: 30.days.ago, last_webfingered_at: nil, username: 'bob', uri: 'https://example.org/users/bob', domain: 'example.org', protocol: :activitypub) }
    let!(:gon)   { Fabricate(:account, updated_at: 15.days.ago, last_webfingered_at: 15.days.ago, username: 'gon', uri: 'https://example.net/users/gon', domain: 'example.net', protocol: :activitypub) }
    let!(:ana)   { Fabricate(:account, username: 'ana', uri: 'https://example.com/users/ana', domain: 'example.com', protocol: :activitypub) }
    let!(:tales) { Fabricate(:account, updated_at: 10.days.ago, last_webfingered_at: nil, username: 'tales', uri: 'https://example.net/users/tales', domain: 'example.net', protocol: :activitypub) }

    before do
      allow(DeleteAccountService).to receive(:new).and_return(delete_account_service)
    end

    context 'when no domain is specified' do
      before do
        stub_parallelize_with_progress!
        stub_request(:head, 'https://example.org/users/bob').to_return(status: 404)
        stub_request(:head, 'https://example.net/users/gon').to_return(status: 410)
        stub_request(:head, 'https://example.net/users/tales').to_return(status: 200)
      end

      it 'deletes all inactive remote accounts that longer exist in the origin server' do
        subject

        expect(delete_account_service).to have_received(:call).with(bob, reserve_username: false).once
        expect(delete_account_service).to have_received(:call).with(gon, reserve_username: false).once
      end

      it 'does not delete any active remote account that still exists in the origin server' do
        subject

        expect(delete_account_service).to_not have_received(:call).with(tom, reserve_username: false)
        expect(delete_account_service).to_not have_received(:call).with(ana, reserve_username: false)
        expect(delete_account_service).to_not have_received(:call).with(tales, reserve_username: false)
      end

      it 'touches inactive remote accounts that have not been deleted' do
        expect { subject }.to(change { tales.reload.updated_at })
      end

      it 'displays the summary correctly' do
        expect { subject }
          .to output_results('Visited 5 accounts, removed 2')
      end
    end

    context 'when a domain is specified' do
      let(:arguments) { ['example.net'] }

      before do
        stub_parallelize_with_progress!
        stub_request(:head, 'https://example.net/users/gon').to_return(status: 410)
        stub_request(:head, 'https://example.net/users/tales').to_return(status: 404)
      end

      it 'deletes inactive remote accounts that longer exist in the specified domain' do
        subject

        expect(delete_account_service).to have_received(:call).with(gon, reserve_username: false).once
        expect(delete_account_service).to have_received(:call).with(tales, reserve_username: false).once
      end

      it 'displays the summary correctly' do
        expect { subject }
          .to output_results('Visited 2 accounts, removed 2')
      end
    end

    context 'when a domain is unavailable' do
      shared_examples 'an unavailable domain' do
        before do
          stub_parallelize_with_progress!
          stub_request(:head, 'https://example.org/users/bob').to_return(status: 200)
          stub_request(:head, 'https://example.net/users/gon').to_return(status: 200)
        end

        it 'skips accounts from the unavailable domain' do
          subject

          expect(delete_account_service).to_not have_received(:call).with(tales, reserve_username: false)
        end

        it 'displays the summary correctly' do
          expect { subject }
            .to output_results("Visited 5 accounts, removed 0\nThe following domains were not available during the check:\n    example.net")
        end
      end

      context 'when a connection timeout occurs' do
        before do
          stub_request(:head, 'https://example.net/users/tales').to_timeout
        end

        it_behaves_like 'an unavailable domain'
      end

      context 'when a connection error occurs' do
        before do
          stub_request(:head, 'https://example.net/users/tales').to_raise(HTTP::ConnectionError)
        end

        it_behaves_like 'an unavailable domain'
      end

      context 'when an ssl error occurs' do
        before do
          stub_request(:head, 'https://example.net/users/tales').to_raise(OpenSSL::SSL::SSLError)
        end

        it_behaves_like 'an unavailable domain'
      end

      context 'when a private network address error occurs' do
        before do
          stub_request(:head, 'https://example.net/users/tales').to_raise(Mastodon::PrivateNetworkAddressError)
        end

        it_behaves_like 'an unavailable domain'
      end
    end
  end

  describe '#reset_relationships' do
    let(:action) { :reset_relationships }
    let(:target_account) { Fabricate(:account) }
    let(:arguments)      { [target_account.username] }

    context 'when no option is given' do
      it 'exits with an error message indicating that at least one option is required' do
        expect { subject }
          .to output_results('Please specify either --follows or --followers, or both')
          .and raise_error(SystemExit)
      end
    end

    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }
      let(:options) { { follows: true } }

      it 'exits with an error message indicating that there is no such account' do
        expect { subject }
          .to output_results('No such account')
          .and raise_error(SystemExit)
      end
    end

    context 'when the given username is found' do
      let(:total_relationships) { 3 }
      let!(:accounts)           { Fabricate.times(total_relationships, :account) }

      context 'with --follows option' do
        let(:options) { { follows: true } }

        before do
          accounts.each { |account| target_account.follow!(account) }
        end

        it 'resets all "following" relationships from the target account' do
          subject

          expect(target_account.reload.following).to be_empty
        end

        it 'calls BootstrapTimelineWorker once to rebuild the timeline' do
          allow(BootstrapTimelineWorker).to receive(:perform_async)

          subject

          expect(BootstrapTimelineWorker).to have_received(:perform_async).with(target_account.id).once
        end

        it 'displays a successful message' do
          expect { subject }
            .to output_results("Processed #{total_relationships} relationships")
        end
      end

      context 'with --followers option' do
        let(:options) { { followers: true } }

        before do
          accounts.each { |account| account.follow!(target_account) }
        end

        it 'resets all "followers" relationships from the target account' do
          subject

          expect(target_account.reload.followers).to be_empty
        end

        it 'displays a successful message' do
          expect { subject }
            .to output_results("Processed #{total_relationships} relationships")
        end
      end

      context 'with --follows and --followers options' do
        let(:options) { { followers: true, follows: true } }

        before do
          accounts.first(2).each { |account| account.follow!(target_account) }
          accounts.last(1).each  { |account| target_account.follow!(account) }
        end

        it 'resets all "followers" relationships from the target account' do
          subject

          expect(target_account.reload.followers).to be_empty
        end

        it 'resets all "following" relationships from the target account' do
          subject

          expect(target_account.reload.following).to be_empty
        end

        it 'calls BootstrapTimelineWorker once to rebuild the timeline' do
          allow(BootstrapTimelineWorker).to receive(:perform_async)

          subject

          expect(BootstrapTimelineWorker).to have_received(:perform_async).with(target_account.id).once
        end

        it 'displays a successful message' do
          expect { subject }
            .to output_results("Processed #{total_relationships} relationships")
        end
      end
    end
  end

  describe '#prune' do
    let(:action) { :prune }
    let!(:local_account)     { Fabricate(:account) }
    let!(:bot_account)       { Fabricate(:account, bot: true, domain: 'example.com') }
    let!(:group_account)     { Fabricate(:account, actor_type: 'Group', domain: 'example.com') }
    let!(:mentioned_account) { Fabricate(:account, domain: 'example.com') }
    let!(:prunable_accounts) do
      Fabricate.times(2, :account, domain: 'example.com', bot: false, suspended_at: nil, silenced_at: nil)
    end

    before do
      Fabricate(:mention, account: mentioned_account, status: Fabricate(:status, account: Fabricate(:account)))
      stub_parallelize_with_progress!
    end

    it 'prunes all remote accounts with no interactions with local users' do
      subject

      prunable_account_ids = prunable_accounts.pluck(:id)

      expect(Account.where(id: prunable_account_ids).count).to eq(0)
    end

    it 'displays a successful message' do
      expect { subject }
        .to output_results("OK, pruned #{prunable_accounts.size} accounts")
    end

    it 'does not prune local accounts' do
      subject

      expect(Account.exists?(id: local_account.id)).to be(true)
    end

    it 'does not prune bot accounts' do
      subject

      expect(Account.exists?(id: bot_account.id)).to be(true)
    end

    it 'does not prune group accounts' do
      subject

      expect(Account.exists?(id: group_account.id)).to be(true)
    end

    it 'does not prune accounts that have been mentioned' do
      subject

      expect(Account.exists?(id: mentioned_account.id)).to be true
    end

    context 'with --dry-run option' do
      let(:options) { { dry_run: true } }

      it 'does not prune any account' do
        subject

        prunable_account_ids = prunable_accounts.pluck(:id)

        expect(Account.where(id: prunable_account_ids).count).to eq(prunable_accounts.size)
      end

      it 'displays a successful message with (DRY RUN)' do
        expect { subject }
          .to output_results("OK, pruned #{prunable_accounts.size} accounts (DRY RUN)")
      end
    end
  end

  describe '#migrate' do
    let(:action) { :migrate }
    let!(:source_account)         { Fabricate(:account) }
    let!(:target_account)         { Fabricate(:account, domain: 'example.com') }
    let(:arguments)               { [source_account.username] }
    let(:resolve_account_service) { instance_double(ResolveAccountService, call: nil) }
    let(:move_service)            { instance_double(MoveService, call: nil) }

    before do
      allow(ResolveAccountService).to receive(:new).and_return(resolve_account_service)
      allow(MoveService).to receive(:new).and_return(move_service)
    end

    shared_examples 'a successful migration' do
      it 'calls the MoveService for the last migration' do
        subject

        last_migration = source_account.migrations.last

        expect(move_service).to have_received(:call).with(last_migration).once
      end

      it 'displays a successful message' do
        expect { subject }
          .to output_results("OK, migrated #{source_account.acct} to #{target_account.acct}")
      end
    end

    context 'when both --replay and --target options are given' do
      let(:options) { { replay: true, target: "#{target_account.username}@example.com" } }

      it 'exits with an error message indicating that using both options is not possible' do
        expect { subject }
          .to output_results('Use --replay or --target, not both')
          .and raise_error(SystemExit)
      end
    end

    context 'when no option is given' do
      it 'exits with an error message indicating that at least one option must be used' do
        expect { subject }
          .to output_results('Use either --replay or --target')
          .and raise_error(SystemExit)
      end
    end

    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }
      let(:options) { { replay: true } }

      it 'exits with an error message indicating that there is no such account' do
        expect { subject }
          .to output_results("No such account: #{arguments.first}")
          .and raise_error(SystemExit)
      end
    end

    context 'with --replay option' do
      let(:options) { { replay: true } }

      context 'when the specified account has no previous migrations' do
        it 'exits with an error message indicating that the given account has no previous migrations' do
          expect { subject }
            .to output_results('The specified account has not performed any migration')
            .and raise_error(SystemExit)
        end
      end

      context 'when the specified account has a previous migration' do
        before do
          allow(resolve_account_service).to receive(:call).with(source_account.acct, any_args).and_return(source_account)
          allow(resolve_account_service).to receive(:call).with(target_account.acct, any_args).and_return(target_account)
          target_account.aliases.create!(acct: source_account.acct)
          source_account.migrations.create!(acct: target_account.acct)
          source_account.update!(moved_to_account: target_account)
        end

        it_behaves_like 'a successful migration'

        context 'when the specified account is redirecting to a different target account' do
          before do
            source_account.update!(moved_to_account: nil)
          end

          it 'exits with an error message' do
            expect { subject }
              .to output_results('The specified account is not redirecting to its last migration target. Use --force if you want to replay the migration anyway')
              .and raise_error(SystemExit)
          end
        end

        context 'with --force option' do
          let(:options) { { replay: true, force: true } }

          it_behaves_like 'a successful migration'
        end
      end
    end

    context 'with --target option' do
      let(:options) { { target: target_account.acct } }

      before do
        allow(resolve_account_service).to receive(:call).with(source_account.acct, any_args).and_return(source_account)
        allow(resolve_account_service).to receive(:call).with(target_account.acct, any_args).and_return(target_account)
      end

      context 'when the specified target account is not found' do
        before do
          allow(resolve_account_service).to receive(:call).with(target_account.acct).and_return(nil)
        end

        it 'exits with an error message indicating that there is no such account' do
          expect { subject }
            .to output_results("The specified target account could not be found: #{options[:target]}")
            .and raise_error(SystemExit)
        end
      end

      context 'when the specified target account exists' do
        before do
          target_account.aliases.create!(acct: source_account.acct)
        end

        it 'creates a migration for the specified account with the target account' do
          subject

          last_migration = source_account.migrations.last

          expect(last_migration.acct).to eq(target_account.acct)
        end

        it_behaves_like 'a successful migration'
      end

      context 'when the migration record is invalid' do
        it 'exits with an error indicating that the validation failed' do
          expect { subject }
            .to output_results('Error: Validation failed')
            .and raise_error(SystemExit)
        end
      end

      context 'when the specified account is redirecting to a different target account' do
        before do
          source_account.update(moved_to_account: Fabricate(:account))
        end

        it 'exits with an error message' do
          expect { subject }
            .to output_results('The specified account is redirecting to a different target account. Use --force if you want to change the migration target')
            .and raise_error(SystemExit)
        end
      end

      context 'with --target and --force options' do
        let(:options) { { target: target_account.acct, force: true } }

        before do
          source_account.update(moved_to_account: Fabricate(:account))
          target_account.aliases.create!(acct: source_account.acct)
        end

        it_behaves_like 'a successful migration'
      end
    end
  end
end
