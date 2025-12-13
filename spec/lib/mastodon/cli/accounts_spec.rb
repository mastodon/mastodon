# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts do
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
    let(:username) { 'tootctl_username' }

    shared_examples 'a new user with given email address and username' do
      it 'creates user and accounts from options and displays success message' do
        allow(SecureRandom).to receive(:hex).and_return('test_password')

        expect { subject }
          .to output_results('OK', 'New password: test_password')
        expect(user_from_options).to be_present
        expect(account_from_options).to be_present
      end

      def user_from_options
        User.find_by(email: options[:email])
      end

      def account_from_options
        Account.find_local(username)
      end
    end

    context 'when required USERNAME and --email are provided' do
      let(:arguments) { [username] }

      context 'with USERNAME and --email only' do
        let(:options) { { email: 'tootctl@example.com' } }

        it_behaves_like 'a new user with given email address and username'

        context 'with a reserved username' do
          let(:username) { 'security' }

          it_behaves_like 'a new user with given email address and username'
        end

        context 'with invalid --email value' do
          let(:options) { { email: 'invalid' } }

          it 'exits with an error message' do
            expect { subject }
              .to raise_error(Thor::Error, %r{Failure/Error: email})
          end
        end
      end

      context 'with min_age setting' do
        let(:options) { { email: 'tootctl@example.com', confirmed: true } }

        before do
          Setting.min_age = 42
        end

        it_behaves_like 'a new user with given email address and username'

        it 'creates a new user with confirmed status' do
          expect { subject }
            .to output_results('New password')

          user = User.find_by(email: options[:email])

          expect(user.confirmed?).to be(true)
        end
      end

      context 'with --confirmed option' do
        let(:options) { { email: 'tootctl@example.com', confirmed: true } }

        it_behaves_like 'a new user with given email address and username'

        it 'creates a new user with confirmed status' do
          expect { subject }
            .to output_results('New password')

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
          expect { subject }
            .to output_results('New password')

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
            expect { subject }
              .to output_results('New password')

            role = User.find_by(email: options[:email])&.role

            expect(role.name).to eq(default_role.name)
          end
        end

        context 'when role does not exist' do
          let(:options) { { email: 'tootctl@example.com', role: '404' } }

          it 'exits with an error message indicating the role name was not found' do
            expect { subject }
              .to raise_error(Thor::Error, 'Cannot find user role with that name')
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
              expect { subject }
                .to output_results('New password')

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
          .to raise_error(Thor::Error, 'No user with such username')
      end
    end

    context 'when the given username is found' do
      let(:user) { Fabricate(:user) }
      let(:arguments) { [user.account.username] }

      context 'when no option is provided' do
        it 'returns a successful message and preserves user' do
          expect { subject }
            .to output_results('OK')
          expect(user).to eq(user.reload)
        end
      end

      context 'with --role option' do
        context 'when the given role is not found' do
          let(:options) { { role: '404' } }

          it 'exits with an error message indicating the role was not found' do
            expect { subject }
              .to raise_error(Thor::Error, 'Cannot find user role with that name')
          end
        end

        context 'when the given role is found' do
          let(:default_role) { Fabricate(:user_role) }
          let(:options) { { role: default_role.name } }

          it "updates the user's role to the specified role" do
            expect { subject }
              .to output_results('OK')

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
          expect { subject }
            .to output_results('OK')

          role = user.reload.role

          expect(role.name).to be_empty
        end
      end

      context 'with --email option' do
        let(:user) { Fabricate(:user, email: 'old_email@email.com') }
        let(:options) { { email: 'new_email@email.com' } }

        it "sets the user's unconfirmed email to the provided email address" do
          expect { subject }
            .to output_results('OK')

          expect(user.reload.unconfirmed_email).to eq(options[:email])
        end

        it "does not update the user's original email address" do
          expect { subject }
            .to output_results('OK')

          expect(user.reload.email).to eq('old_email@email.com')
        end

        context 'with --confirm option' do
          let(:user) { Fabricate(:user, email: 'old_email@email.com', confirmed_at: nil) }
          let(:options) { { email: 'new_email@email.com', confirm: true } }

          it "updates the user's email address to the provided email" do
            expect { subject }
              .to output_results('OK')

            expect(user.reload.email).to eq(options[:email])
          end

          it "sets the user's email address as confirmed" do
            expect { subject }
              .to output_results('OK')

            expect(user.reload.confirmed?).to be(true)
          end
        end
      end

      context 'with --confirm option' do
        let(:user) { Fabricate(:user, confirmed_at: nil) }
        let(:options) { { confirm: true } }

        it "confirms the user's email address" do
          expect { subject }
            .to output_results('OK')

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
          expect { subject }
            .to output_results('OK')
            .and change { user.reload.approved }.from(false).to(true)
        end
      end

      context 'with --disable option' do
        let(:user) { Fabricate(:user, disabled: false) }
        let(:options) { { disable: true } }

        it 'disables the user' do
          expect { subject }
            .to output_results('OK')
            .and change { user.reload.disabled }.from(false).to(true)
        end
      end

      context 'with --enable option' do
        let(:user) { Fabricate(:user, disabled: true) }
        let(:options) { { enable: true } }

        it 'enables the user' do
          expect { subject }
            .to output_results('OK')
            .and change { user.reload.disabled }.from(true).to(false)
        end
      end

      context 'with --reset-password option' do
        let(:options) { { reset_password: true } }

        let(:user) { Fabricate(:user, password: original_password) }
        let(:original_password) { 'foobar12345' }
        let(:new_password) { 'new_password12345' }

        it 'returns a new password for the user' do
          allow(SecureRandom).to receive(:hex).and_return(new_password)
          allow(Account).to receive(:find_local).and_return(user.account)
          allow(user).to receive(:change_password!).and_call_original

          expect { subject }
            .to output_results(new_password)

          expect(user).to have_received(:change_password!).with(new_password)
          expect(user.reload).to_not be_external_or_valid_password(original_password)
        end
      end

      context 'with --disable-2fa option' do
        let(:user) { Fabricate(:user, otp_required_for_login: true) }
        let(:options) { { disable_2fa: true } }

        it 'disables the two-factor authentication for the user' do
          expect { subject }
            .to output_results('OK')
            .and change { user.reload.otp_required_for_login }.from(true).to(false)
        end
      end

      context 'when provided data is invalid' do
        let(:user) { Fabricate(:user) }
        let(:options) { { email: 'invalid' } }

        it 'exits with an error message' do
          expect { subject }
            .to raise_error(Thor::Error, %r{Failure/Error: email})
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
          .to raise_error(Thor::Error, 'Use username or --email, not both')
      end
    end

    context 'when neither username nor --email are provided' do
      it 'exits with an error message indicating that no username was provided' do
        expect { subject }
          .to raise_error(Thor::Error, 'No username provided')
      end
    end

    context 'when username is provided' do
      let(:arguments) { [account.username] }

      it 'deletes the specified user successfully' do
        expect { subject }
          .to output_results('Deleting')

        expect(delete_account_service).to have_received(:call).with(account, reserve_email: false).once
      end

      context 'with --dry-run option' do
        let(:options) { { dry_run: true } }

        it 'outputs a successful message in dry run mode and does not delete the user' do
          expect { subject }
            .to output_results('OK (DRY RUN)')
          expect(delete_account_service).to_not have_received(:call).with(account, reserve_email: false)
        end
      end

      context 'when the given username is not found' do
        let(:arguments) { ['non_existent_username'] }

        it 'exits with an error message indicating that no user was found' do
          expect { subject }
            .to raise_error(Thor::Error, 'No user with such username')
        end
      end
    end

    context 'when --email is provided' do
      let(:options) { { email: account.user.email } }

      it 'deletes the specified user successfully' do
        expect { subject }
          .to output_results('Deleting')

        expect(delete_account_service).to have_received(:call).with(account, reserve_email: false).once
      end

      context 'with --dry-run option' do
        let(:options) { { email: account.user.email, dry_run: true } }

        it 'outputs a successful message in dry run mode and does not delete the user' do
          expect { subject }
            .to output_results('OK (DRY RUN)')
          expect(delete_account_service)
            .to_not have_received(:call)
            .with(account, reserve_email: false)
        end
      end

      context 'when the given email address is not found' do
        let(:options) { { email: '404@example.com' } }

        it 'exits with an error message indicating that no user was found' do
          expect { subject }
            .to raise_error(Thor::Error, 'No user with such email')
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
        expect { subject }
          .to output_results('OK')

        expect(User.pluck(:approved).all?(true)).to be(true)
      end
    end

    context 'with --number option' do
      context 'when the number is positive' do
        let(:options) { { number: 2 } }

        it 'approves the earliest n pending registrations but not the remaining ones' do
          expect { subject }
            .to output_results('OK')

          expect(n_earliest_pending_registrations.all?(&:approved?)).to be(true)
          expect(pending_registrations.all?(&:approved?)).to be(false)
        end

        def n_earliest_pending_registrations
          User.order(created_at: :asc).first(options[:number])
        end

        def pending_registrations
          User.order(created_at: :asc).last(total_users - options[:number])
        end
      end

      context 'when the number is negative' do
        let(:options) { { number: -1 } }

        it 'exits with an error message indicating that the number must be positive' do
          expect { subject }
            .to raise_error(Thor::Error, 'Number must be positive')
        end
      end

      context 'when the given number is greater than the number of users' do
        let(:options) { { number: total_users * 2 } }

        it 'approves all users and does not raise any error' do
          expect { subject }
            .to output_results('OK')
          expect(User.pluck(:approved).all?(true)).to be(true)
        end
      end
    end

    context 'with username argument' do
      context 'when the given username is found' do
        let(:user) { User.last }
        let(:arguments) { [user.account.username] }

        it 'approves the specified user successfully' do
          expect { subject }
            .to output_results('OK')

          expect(user.reload.approved?).to be(true)
        end
      end

      context 'when the given username is not found' do
        let(:arguments) { ['non_existent_username'] }

        it 'exits with an error message indicating that no such account was found' do
          expect { subject }
            .to raise_error(Thor::Error, 'No such account')
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
          .to raise_error(Thor::Error, 'No such account')
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

      it 'displays a successful message and makes all local accounts follow the target account' do
        expect { subject }
          .to output_results("OK, followed target from #{Account.local.count} accounts")
        expect(follow_service).to have_received(:call).with(follower_bob, target_account, any_args).once
        expect(follow_service).to have_received(:call).with(follower_rony, target_account, any_args).once
        expect(follow_service).to have_received(:call).with(follower_charles, target_account, any_args).once
      end
    end
  end

  describe '#unfollow' do
    let(:action) { :unfollow }

    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'exits with an error message indicating that no account with the given username was found' do
        expect { subject }
          .to raise_error(Thor::Error, 'No such account')
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

      it 'displays a successful message and makes all local accounts unfollow the target account' do
        expect { subject }
          .to output_results('OK, unfollowed target from 3 accounts')
        expect(unfollow_service).to have_received(:call).with(follower_chris, target_account).once
        expect(unfollow_service).to have_received(:call).with(follower_rambo, target_account).once
        expect(unfollow_service).to have_received(:call).with(follower_ana, target_account).once
      end
    end
  end

  describe '#fix_duplicates' do
    let(:action) { :fix_duplicates }
    let(:service_double) { instance_double(ActivityPub::FetchRemoteAccountService, call: nil) }
    let(:uri) { 'https://host.example/same/value' }

    context 'when there are duplicate URI accounts' do
      before do
        Fabricate.times(2, :account, domain: 'host.example', uri: uri)
        allow(ActivityPub::FetchRemoteAccountService).to receive(:new).and_return(service_double)
      end

      it 'finds the duplicates and calls fetch remote account service' do
        expect { subject }
          .to output_results('Duplicates found')
        expect(service_double).to have_received(:call).with(uri)
      end
    end
  end

  describe '#backup' do
    let(:action) { :backup }

    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'exits with an error message indicating that there is no such account' do
        expect { subject }
          .to raise_error(Thor::Error, 'No user with such username')
      end
    end

    context 'when the given username is found' do
      let(:account) { Fabricate(:account) }
      let(:user) { account.user }
      let(:arguments) { [account.username] }

      before { allow(BackupWorker).to receive(:perform_async) }

      it 'creates a new backup and backup job for the specified user and outputs success message' do
        expect { subject }
          .to change { user.backups.count }.by(1)
          .and output_results('OK')
        expect(BackupWorker).to have_received(:perform_async).with(latest_backup.id).once
      end

      def latest_backup
        user.backups.last
      end
    end
  end

  describe '#refresh' do
    let(:action) { :refresh }

    context 'with --all option' do
      let(:options) { { all: true } }
      let!(:local_account) { Fabricate(:account, domain: nil) }
      let(:remote_com_avatar_url) { 'https://example.host/avatar/com' }
      let(:remote_com_header_url) { 'https://example.host/header/com' }
      let(:remote_account_example_com) { Fabricate(:account, domain: 'example.com', avatar_remote_url: remote_com_avatar_url, header_remote_url: remote_com_header_url) }
      let(:remote_net_avatar_url) { 'https://example.host/avatar/net' }
      let(:remote_net_header_url) { 'https://example.host/header/net' }
      let(:account_example_net) { Fabricate(:account, domain: 'example.net', avatar_remote_url: remote_net_avatar_url, header_remote_url: remote_net_header_url) }
      let(:scope) { Account.remote }

      before do
        stub_parallelize_with_progress!

        stub_request(:get, remote_com_avatar_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, remote_com_header_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, remote_net_avatar_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, remote_net_header_url)
          .to_return request_fixture('avatar.txt')

        remote_account_example_com
          .update_column(:avatar_file_name, nil)
        account_example_net
          .update_column(:avatar_file_name, nil)
      end

      it 'refreshes the avatar and header for all remote accounts' do
        expect { subject }
          .to output_results('Refreshed 2 accounts')
          .and not_change(local_account, :updated_at)

        # One request from factory creation, one more from task
        expect(a_request(:get, remote_com_avatar_url))
          .to have_been_made.at_least_times(2)
        expect(a_request(:get, remote_com_header_url))
          .to have_been_made.at_least_times(2)
        expect(a_request(:get, remote_net_avatar_url))
          .to have_been_made.at_least_times(2)
        expect(a_request(:get, remote_net_header_url))
          .to have_been_made.at_least_times(2)
      end

      context 'with --dry-run option' do
        let(:options) { { all: true, dry_run: true } }

        it 'does not refresh the avatar or header for any account' do
          expect { subject }
            .to output_results('Refreshed 2 accounts')

          # One request from factory creation, none from task due to dry run
          expect(a_request(:get, remote_com_avatar_url))
            .to have_been_made.once
          expect(a_request(:get, remote_com_header_url))
            .to have_been_made.once
          expect(a_request(:get, remote_net_avatar_url))
            .to have_been_made.once
          expect(a_request(:get, remote_net_header_url))
            .to have_been_made.once
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

        expect { subject }
          .to output_results('OK')

        expect(account_example_com_a).to have_received(:reset_avatar!).once
        expect(account_example_com_b).to have_received(:reset_avatar!).once
      end

      it 'does not reset the avatar for unspecified accounts' do
        allow(account_example_net).to receive(:reset_avatar!)

        expect { subject }
          .to output_results('OK')

        expect(account_example_net).to_not have_received(:reset_avatar!)
      end

      it 'resets the header for the specified accounts' do
        allow(account_example_com_a).to receive(:reset_header!)
        allow(account_example_com_b).to receive(:reset_header!)

        expect { subject }
          .to output_results('OK')

        expect(account_example_com_a).to have_received(:reset_header!).once
        expect(account_example_com_b).to have_received(:reset_header!).once
      end

      it 'does not reset the header for unspecified accounts' do
        allow(account_example_net).to receive(:reset_header!)

        expect { subject }
          .to output_results('OK')

        expect(account_example_net).to_not have_received(:reset_header!)
      end

      context 'when an UnexpectedResponseError is raised' do
        it 'displays a failure message' do
          allow(account_example_com_a).to receive(:reset_avatar!).and_raise(Mastodon::UnexpectedResponseError)

          expect { subject }
            .to output_results("Account failed: #{account_example_com_a.username}@#{account_example_com_a.domain}")
        end
      end

      context 'when a specified account is not found' do
        it 'exits with an error message' do
          allow(Account).to receive(:find_remote).with(account_example_com_b.username, account_example_com_b.domain).and_return(nil)

          expect { subject }
            .to raise_error(Thor::Error, 'No such account')
        end
      end

      context 'with --dry-run option' do
        let(:options) { { dry_run: true } }

        it 'does not refresh the avatar for any account' do
          allow(account_example_com_a).to receive(:reset_avatar!)
          allow(account_example_com_b).to receive(:reset_avatar!)

          expect { subject }
            .to output_results('OK (DRY RUN)')

          expect(account_example_com_a).to_not have_received(:reset_avatar!)
          expect(account_example_com_b).to_not have_received(:reset_avatar!)
        end

        it 'does not refresh the header for any account' do
          allow(account_example_com_a).to receive(:reset_header!)
          allow(account_example_com_b).to receive(:reset_header!)

          expect { subject }
            .to output_results('OK (DRY RUN)')

          expect(account_example_com_a).to_not have_received(:reset_header!)
          expect(account_example_com_b).to_not have_received(:reset_header!)
        end
      end
    end

    context 'with --domain option' do
      let(:domain) { 'example.com' }
      let(:options) { { domain: domain } }

      let(:com_a_avatar_url) { 'https://example.host/avatar/a' }
      let(:com_a_header_url) { 'https://example.host/header/a' }
      let(:account_example_com_a) { Fabricate(:account, domain: domain, avatar_remote_url: com_a_avatar_url, header_remote_url: com_a_header_url) }

      let(:com_b_avatar_url) { 'https://example.host/avatar/b' }
      let(:com_b_header_url) { 'https://example.host/header/b' }
      let(:account_example_com_b) { Fabricate(:account, domain: domain, avatar_remote_url: com_b_avatar_url, header_remote_url: com_b_header_url) }

      let(:net_avatar_url) { 'https://example.host/avatar/net' }
      let(:net_header_url) { 'https://example.host/header/net' }
      let(:account_example_net) { Fabricate(:account, domain: 'example.net', avatar_remote_url: net_avatar_url, header_remote_url: net_header_url) }

      before do
        stub_parallelize_with_progress!

        stub_request(:get, com_a_avatar_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, com_a_header_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, com_b_avatar_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, com_b_header_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, net_avatar_url)
          .to_return request_fixture('avatar.txt')
        stub_request(:get, net_header_url)
          .to_return request_fixture('avatar.txt')

        account_example_com_a
          .update_column(:avatar_file_name, nil)
        account_example_com_b
          .update_column(:avatar_file_name, nil)
        account_example_net
          .update_column(:avatar_file_name, nil)
      end

      it 'refreshes the avatar and header for all accounts on specified domain' do
        expect { subject }
          .to output_results('Refreshed 2 accounts')

        # One request from factory creation, one more from task
        expect(a_request(:get, com_a_avatar_url))
          .to have_been_made.at_least_times(2)
        expect(a_request(:get, com_a_header_url))
          .to have_been_made.at_least_times(2)
        expect(a_request(:get, com_b_avatar_url))
          .to have_been_made.at_least_times(2)
        expect(a_request(:get, com_b_header_url))
          .to have_been_made.at_least_times(2)

        # One request from factory creation, none from task
        expect(a_request(:get, net_avatar_url))
          .to have_been_made.once
        expect(a_request(:get, net_header_url))
          .to have_been_made.once
      end
    end

    context 'when neither a list of accts nor options are provided' do
      it 'exits with an error message' do
        expect { subject }
          .to raise_error(Thor::Error, 'No account(s) given')
      end
    end
  end

  describe '#rotate' do
    let(:action) { :rotate }

    context 'when neither username nor --all option are given' do
      it 'exits with an error message' do
        expect { subject }
          .to raise_error(Thor::Error, 'No account(s) given')
      end
    end

    context 'when a username is given' do
      let(:account) { Fabricate(:account) }
      let(:arguments) { [account.username] }

      it 'correctly rotates keys for the specified account' do
        old_private_key = account.private_key
        old_public_key = account.public_key

        expect { subject }
          .to output_results('OK')
        account.reload

        expect(account.private_key).to_not eq(old_private_key)
        expect(account.public_key).to_not eq(old_public_key)
      end

      it 'broadcasts the new keys for the specified account' do
        allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_in)

        expect { subject }
          .to output_results('OK')

        expect(ActivityPub::UpdateDistributionWorker).to have_received(:perform_in).with(anything, account.id, anything).once
      end
    end

    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'exits with an error message when the specified username is not found' do
        expect { subject }
          .to raise_error(Thor::Error, 'No such account')
      end
    end

    context 'when --all option is provided' do
      let!(:accounts) { Fabricate.times(2, :account) }
      let(:options) { { all: true } }

      it 'correctly rotates keys for all local accounts' do
        old_private_keys = accounts.map(&:private_key)
        old_public_keys = accounts.map(&:public_key)

        expect { subject }
          .to output_results('rotated')
        accounts.each(&:reload)

        expect(accounts.map(&:private_key)).to_not eq(old_private_keys)
        expect(accounts.map(&:public_key)).to_not eq(old_public_keys)
      end

      it 'broadcasts the new keys for each account' do
        allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_in)

        expect { subject }
          .to output_results('rotated')

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
          .to raise_error(Thor::Error, "No such account (#{acct})")
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
          .to raise_error(Thor::Error, "Accounts don't have the same public key, might not be duplicates!\nOverride with --force\n")
      end

      context 'with --force option' do
        let(:options) { { force: true } }

        before do
          allow(to_account).to receive(:merge_with!)
          allow(from_account).to receive(:destroy)
        end

        it 'merges `from_account` into `to_account` and deletes `from_account`' do
          expect { subject }
            .to output_results('OK')

          expect(to_account).to have_received(:merge_with!).with(from_account).once
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

      it 'merges "from_account" into "to_account" and deletes from_account' do
        expect { subject }
          .to output_results('OK')

        expect(to_account).to have_received(:merge_with!).with(from_account).once
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

      def expect_delete_inactive_remote_accounts
        expect(delete_account_service).to have_received(:call).with(bob, reserve_username: false).once
        expect(delete_account_service).to have_received(:call).with(gon, reserve_username: false).once
      end

      def expect_not_delete_active_accounts
        expect(delete_account_service).to_not have_received(:call).with(tom, reserve_username: false)
        expect(delete_account_service).to_not have_received(:call).with(ana, reserve_username: false)
        expect(delete_account_service).to_not have_received(:call).with(tales, reserve_username: false)
      end

      it 'touches inactive remote accounts that have not been deleted and summarizes activity' do
        expect { subject }
          .to change { tales.reload.updated_at }
          .and output_results('Visited 5 accounts, removed 2')
        expect_delete_inactive_remote_accounts
        expect_not_delete_active_accounts
      end
    end

    context 'when a domain is specified' do
      let(:arguments) { ['example.net'] }

      before do
        stub_parallelize_with_progress!
        stub_request(:head, 'https://example.net/users/gon').to_return(status: 410)
        stub_request(:head, 'https://example.net/users/tales').to_return(status: 404)
      end

      def expect_delete_inactive_remote_accounts
        expect(delete_account_service).to have_received(:call).with(gon, reserve_username: false).once
        expect(delete_account_service).to have_received(:call).with(tales, reserve_username: false).once
      end

      it 'displays the summary correctly and deletes inactive remote accounts' do
        expect { subject }
          .to output_results('Visited 2 accounts, removed 2')
        expect_delete_inactive_remote_accounts
      end
    end

    context 'when a domain is unavailable' do
      shared_examples 'an unavailable domain' do
        before do
          stub_parallelize_with_progress!
          stub_request(:head, 'https://example.org/users/bob').to_return(status: 200)
          stub_request(:head, 'https://example.net/users/gon').to_return(status: 200)
        end

        def expect_skip_accounts_from_unavailable_domain
          expect(delete_account_service).to_not have_received(:call).with(tales, reserve_username: false)
        end

        it 'displays the summary correctly and skip accounts from unavailable domains' do
          expect { subject }
            .to output_results("Visited 5 accounts, removed 0\nThe following domains were not available during the check:\n    example.net")
          expect_skip_accounts_from_unavailable_domain
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
          .to raise_error(Thor::Error, 'Please specify either --follows or --followers, or both')
      end
    end

    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }
      let(:options) { { follows: true } }

      it 'exits with an error message indicating that there is no such account' do
        expect { subject }
          .to raise_error(Thor::Error, 'No such account')
      end
    end

    context 'when the given username is found' do
      let(:total_relationships) { 3 }
      let!(:accounts)           { Fabricate.times(total_relationships, :account) }

      context 'with --follows option' do
        let(:options) { { follows: true } }

        before do
          accounts.each { |account| target_account.follow!(account) }
          allow(BootstrapTimelineWorker).to receive(:perform_async)
        end

        it 'resets following relationships and displays a successful message and rebuilds timeline' do
          expect { subject }
            .to output_results("Processed #{total_relationships} relationships")
          expect(target_account.reload.following).to be_empty
          expect(BootstrapTimelineWorker).to have_received(:perform_async).with(target_account.id).once
        end
      end

      context 'with --followers option' do
        let(:options) { { followers: true } }

        before do
          accounts.each { |account| account.follow!(target_account) }
        end

        it 'resets followers relationships and displays a successful message' do
          expect { subject }
            .to output_results("Processed #{total_relationships} relationships")
          expect(target_account.reload.followers).to be_empty
        end
      end

      context 'with --follows and --followers options' do
        let(:options) { { followers: true, follows: true } }

        before do
          accounts.first(2).each { |account| account.follow!(target_account) }
          accounts.last(1).each  { |account| target_account.follow!(account) }
          allow(BootstrapTimelineWorker).to receive(:perform_async)
        end

        it 'resets followers and following and displays a successful message and rebuilds timeline' do
          expect { subject }
            .to output_results("Processed #{total_relationships} relationships")
          expect(target_account.reload.followers).to be_empty
          expect(target_account.reload.following).to be_empty
          expect(BootstrapTimelineWorker).to have_received(:perform_async).with(target_account.id).once
        end
      end
    end
  end

  describe '#prune' do
    let(:action) { :prune }
    let(:viable_attrs) { { domain: 'example.com', bot: false, suspended: false, silenced: false } }
    let!(:local_account) { Fabricate(:account) }
    let!(:bot_account) { Fabricate(:account, bot: true, domain: 'example.com') }
    let!(:group_account) { Fabricate(:account, actor_type: 'Group', domain: 'example.com') }
    let!(:account_mentioned) { Fabricate(:account, viable_attrs) }
    let!(:account_with_favourite) { Fabricate(:account, viable_attrs) }
    let!(:account_with_status) { Fabricate(:account, viable_attrs) }
    let!(:account_with_follow) { Fabricate(:account, viable_attrs) }
    let!(:account_targeted_follow) { Fabricate(:account, viable_attrs) }
    let!(:account_with_block) { Fabricate(:account, viable_attrs) }
    let!(:account_targeted_block) { Fabricate(:account, viable_attrs) }
    let!(:account_targeted_mute) { Fabricate(:account, viable_attrs) }
    let!(:account_targeted_report) { Fabricate(:account, viable_attrs) }
    let!(:account_with_follow_request) { Fabricate(:account, viable_attrs) }
    let!(:account_targeted_follow_request) { Fabricate(:account, viable_attrs) }
    let!(:prunable_accounts) { Fabricate.times(2, :account, viable_attrs) }

    before do
      Fabricate :mention, account: account_mentioned, status: Fabricate(:status, account: Fabricate(:account))
      Fabricate :favourite, account: account_with_favourite
      Fabricate :status, account: account_with_status
      Fabricate :follow, account: account_with_follow
      Fabricate :follow, target_account: account_targeted_follow
      Fabricate :block, account: account_with_block
      Fabricate :block, target_account: account_targeted_block
      Fabricate :mute, target_account: account_targeted_mute
      Fabricate :report, target_account: account_targeted_report
      Fabricate :follow_request, account: account_with_follow_request
      Fabricate :follow_request, target_account: account_targeted_follow_request
      stub_parallelize_with_progress!
    end

    it 'displays a successful message and handles accounts correctly' do
      expect { subject }
        .to output_results("OK, pruned #{prunable_accounts.size} accounts")
      expect(prunable_account_records)
        .to have_attributes(count: eq(0))
      expect(Account.all)
        .to include(local_account)
        .and include(bot_account)
        .and include(group_account)
        .and include(account_mentioned)
        .and include(account_with_favourite)
        .and include(account_with_status)
        .and include(account_with_follow)
        .and include(account_targeted_follow)
        .and include(account_with_block)
        .and include(account_targeted_block)
        .and include(account_targeted_mute)
        .and include(account_targeted_report)
        .and include(account_with_follow_request)
        .and include(account_targeted_follow_request)
        .and not_include(prunable_accounts.first)
        .and not_include(prunable_accounts.last)
    end

    def prunable_account_records
      Account.where(id: prunable_accounts.pluck(:id))
    end

    context 'with --dry-run option' do
      let(:options) { { dry_run: true } }

      def expect_no_account_prunes
        prunable_account_ids = prunable_accounts.pluck(:id)

        expect(Account.where(id: prunable_account_ids).count).to eq(prunable_accounts.size)
      end

      it 'displays a successful message with (DRY RUN) and doesnt prune anything' do
        expect { subject }
          .to output_results("OK, pruned #{prunable_accounts.size} accounts (DRY RUN)")
        expect_no_account_prunes
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
      it 'displays a success message and calls the MoveService for the last migration' do
        expect { subject }
          .to output_results("OK, migrated #{source_account.acct} to #{target_account.acct}")

        expect(move_service)
          .to have_received(:call).with(last_migration).once
      end

      def last_migration
        source_account.migrations.last
      end
    end

    context 'when both --replay and --target options are given' do
      let(:options) { { replay: true, target: "#{target_account.username}@example.com" } }

      it 'exits with an error message indicating that using both options is not possible' do
        expect { subject }
          .to raise_error(Thor::Error, 'Use --replay or --target, not both')
      end
    end

    context 'when no option is given' do
      it 'exits with an error message indicating that at least one option must be used' do
        expect { subject }
          .to raise_error(Thor::Error, 'Use either --replay or --target')
      end
    end

    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }
      let(:options) { { replay: true } }

      it 'exits with an error message indicating that there is no such account' do
        expect { subject }
          .to raise_error(Thor::Error, "No such account: #{arguments.first}")
      end
    end

    context 'with --replay option' do
      let(:options) { { replay: true } }

      context 'when the specified account has no previous migrations' do
        it 'exits with an error message indicating that the given account has no previous migrations' do
          expect { subject }
            .to raise_error(Thor::Error, 'The specified account has not performed any migration')
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
              .to raise_error(Thor::Error, 'The specified account is not redirecting to its last migration target. Use --force if you want to replay the migration anyway')
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
            .to raise_error(Thor::Error, "The specified target account could not be found: #{options[:target]}")
        end
      end

      context 'when the specified target account exists' do
        before do
          target_account.aliases.create!(acct: source_account.acct)
        end

        it 'creates a migration for the specified account with the target account' do
          expect { subject }
            .to output_results('migrated')

          last_migration = source_account.migrations.last

          expect(last_migration.acct).to eq(target_account.acct)
        end

        it_behaves_like 'a successful migration'
      end

      context 'when the migration record is invalid' do
        it 'exits with an error indicating that the validation failed' do
          expect { subject }
            .to raise_error(Thor::Error, /Error: Validation failed/)
        end
      end

      context 'when the specified account is redirecting to a different target account' do
        before do
          source_account.update(moved_to_account: Fabricate(:account))
        end

        it 'exits with an error message' do
          expect { subject }
            .to raise_error(Thor::Error, 'The specified account is redirecting to a different target account. Use --force if you want to change the migration target')
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
