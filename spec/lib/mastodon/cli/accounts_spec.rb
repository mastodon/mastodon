# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

describe Mastodon::CLI::Accounts do
  let(:cli) { described_class.new }

  describe '.exit_on_failure?' do
    it 'returns true' do
      expect(described_class.exit_on_failure?).to be true
    end
  end

  describe '#create' do
    shared_examples 'a new user with given email address and username' do
      it 'creates a new user with the specified email address' do
        cli.invoke(:create, arguments, options)

        expect(User.find_by(email: options[:email])).to be_present
      end

      it 'creates a new local account with the specified username' do
        cli.invoke(:create, arguments, options)

        expect(Account.find_local('tootctl_username')).to be_present
      end

      it 'returns "OK" and newly generated password' do
        allow(SecureRandom).to receive(:hex).and_return('test_password')

        expect { cli.invoke(:create, arguments, options) }.to output(
          a_string_including("OK\nNew password: test_password")
        ).to_stdout
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
            expect { cli.invoke(:create, arguments, options) }.to output(
              a_string_including('Failure/Error: email')
            ).to_stdout
              .and raise_error(SystemExit)
          end
        end
      end

      context 'with --confirmed option' do
        let(:options) { { email: 'tootctl@example.com', confirmed: true } }

        it_behaves_like 'a new user with given email address and username'

        it 'creates a new user with confirmed status' do
          cli.invoke(:create, arguments, options)

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
          cli.invoke(:create, arguments, options)

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
            cli.invoke(:create, arguments, options)

            role = User.find_by(email: options[:email])&.role

            expect(role.name).to eq(default_role.name)
          end
        end

        context 'when role does not exist' do
          let(:options) { { email: 'tootctl@example.com', role: '404' } }

          it 'exits with an error message indicating the role name was not found' do
            expect { cli.invoke(:create, arguments, options) }.to output(
              a_string_including('Cannot find user role with that name')
            ).to_stdout
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
            expect { cli.invoke(:create, arguments, options) }.to output(
              a_string_including("The chosen username is currently in use\nUse --force to reattach it anyway and delete the other user")
            ).to_stdout
          end

          context 'with --force option' do
            let(:options) { { email: 'tootctl_new@example.com', reattach: true, force: true } }

            it 'reattaches the account to the new user and deletes the previous user' do
              cli.invoke(:create, arguments, options)

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
        expect { cli.invoke(:create, arguments) }
          .to raise_error(Thor::RequiredArgumentMissingError)
      end
    end
  end

  describe '#modify' do
    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'exits with an error message indicating the user was not found' do
        expect { cli.invoke(:modify, arguments) }.to output(
          a_string_including('No user with such username')
        ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when the given username is found' do
      let(:user) { Fabricate(:user) }
      let(:arguments) { [user.account.username] }

      context 'when no option is provided' do
        it 'returns a successful message' do
          expect { cli.invoke(:modify, arguments) }.to output(
            a_string_including('OK')
          ).to_stdout
        end

        it 'does not modify the user' do
          cli.invoke(:modify, arguments)

          expect(user).to eq(user.reload)
        end
      end

      context 'with --role option' do
        context 'when the given role is not found' do
          let(:options) { { role: '404' } }

          it 'exits with an error message indicating the role was not found' do
            expect { cli.invoke(:modify, arguments, options) }.to output(
              a_string_including('Cannot find user role with that name')
            ).to_stdout
              .and raise_error(SystemExit)
          end
        end

        context 'when the given role is found' do
          let(:default_role) { Fabricate(:user_role) }
          let(:options) { { role: default_role.name } }

          it "updates the user's role to the specified role" do
            cli.invoke(:modify, arguments, options)

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
          cli.invoke(:modify, arguments, options)

          role = user.reload.role

          expect(role.name).to be_empty
        end
      end

      context 'with --email option' do
        let(:user) { Fabricate(:user, email: 'old_email@email.com') }
        let(:options) { { email: 'new_email@email.com' } }

        it "sets the user's unconfirmed email to the provided email address" do
          cli.invoke(:modify, arguments, options)

          expect(user.reload.unconfirmed_email).to eq(options[:email])
        end

        it "does not update the user's original email address" do
          cli.invoke(:modify, arguments, options)

          expect(user.reload.email).to eq('old_email@email.com')
        end

        context 'with --confirm option' do
          let(:user) { Fabricate(:user, email: 'old_email@email.com', confirmed_at: nil) }
          let(:options) { { email: 'new_email@email.com', confirm: true } }

          it "updates the user's email address to the provided email" do
            cli.invoke(:modify, arguments, options)

            expect(user.reload.email).to eq(options[:email])
          end

          it "sets the user's email address as confirmed" do
            cli.invoke(:modify, arguments, options)

            expect(user.reload.confirmed?).to be(true)
          end
        end
      end

      context 'with --confirm option' do
        let(:user) { Fabricate(:user, confirmed_at: nil) }
        let(:options) { { confirm: true } }

        it "confirms the user's email address" do
          cli.invoke(:modify, arguments, options)

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
          expect { cli.invoke(:modify, arguments, options) }.to change { user.reload.approved }.from(false).to(true)
        end
      end

      context 'with --disable option' do
        let(:user) { Fabricate(:user, disabled: false) }
        let(:options) { { disable: true } }

        it 'disables the user' do
          expect { cli.invoke(:modify, arguments, options) }.to change { user.reload.disabled }.from(false).to(true)
        end
      end

      context 'with --enable option' do
        let(:user) { Fabricate(:user, disabled: true) }
        let(:options) { { enable: true } }

        it 'enables the user' do
          expect { cli.invoke(:modify, arguments, options) }.to change { user.reload.disabled }.from(true).to(false)
        end
      end

      context 'with --reset-password option' do
        let(:options) { { reset_password: true } }

        it 'returns a new password for the user' do
          allow(SecureRandom).to receive(:hex).and_return('new_password')

          expect { cli.invoke(:modify, arguments, options) }.to output(
            a_string_including('new_password')
          ).to_stdout
        end
      end

      context 'with --disable-2fa option' do
        let(:user) { Fabricate(:user, otp_required_for_login: true) }
        let(:options) { { disable_2fa: true } }

        it 'disables the two-factor authentication for the user' do
          expect { cli.invoke(:modify, arguments, options) }.to change { user.reload.otp_required_for_login }.from(true).to(false)
        end
      end

      context 'when provided data is invalid' do
        let(:user) { Fabricate(:user) }
        let(:options) { { email: 'invalid' } }

        it 'exits with an error message' do
          expect { cli.invoke(:modify, arguments, options) }.to output(
            a_string_including('Failure/Error: email')
          ).to_stdout
            .and raise_error(SystemExit)
        end
      end
    end
  end

  describe '#delete' do
    let(:account) { Fabricate(:account) }
    let(:arguments) { [account.username] }
    let(:options) { { email: account.user.email } }
    let(:delete_account_service) { instance_double(DeleteAccountService) }

    before do
      allow(DeleteAccountService).to receive(:new).and_return(delete_account_service)
      allow(delete_account_service).to receive(:call)
    end

    context 'when both username and --email are provided' do
      it 'exits with an error message indicating that only one should be used' do
        expect { cli.invoke(:delete, arguments, options) }.to output(
          a_string_including('Use username or --email, not both')
        ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when neither username nor --email are provided' do
      it 'exits with an error message indicating that no username was provided' do
        expect { cli.invoke(:delete) }.to output(
          a_string_including('No username provided')
        ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when username is provided' do
      it 'deletes the specified user successfully' do
        cli.invoke(:delete, arguments)

        expect(delete_account_service).to have_received(:call).with(account, reserve_email: false).once
      end

      context 'with --dry-run option' do
        let(:options) { { dry_run: true } }

        it 'does not delete the specified user' do
          cli.invoke(:delete, arguments, options)

          expect(delete_account_service).to_not have_received(:call).with(account, reserve_email: false)
        end

        it 'outputs a successful message in dry run mode' do
          expect { cli.invoke(:delete, arguments, options) }.to output(
            a_string_including('OK (DRY RUN)')
          ).to_stdout
        end
      end

      context 'when the given username is not found' do
        let(:arguments) { ['non_existent_username'] }

        it 'exits with an error message indicating that no user was found' do
          expect { cli.invoke(:delete, arguments) }.to output(
            a_string_including('No user with such username')
          ).to_stdout
            .and raise_error(SystemExit)
        end
      end
    end

    context 'when --email is provided' do
      it 'deletes the specified user successfully' do
        cli.invoke(:delete, nil, options)

        expect(delete_account_service).to have_received(:call).with(account, reserve_email: false).once
      end

      context 'with --dry-run option' do
        let(:options) { { email: account.user.email, dry_run: true } }

        it 'does not delete the user' do
          cli.invoke(:delete, nil, options)

          expect(delete_account_service).to_not have_received(:call).with(account, reserve_email: false)
        end

        it 'outputs a successful message in dry run mode' do
          expect { cli.invoke(:delete, nil, options) }.to output(
            a_string_including('OK (DRY RUN)')
          ).to_stdout
        end
      end

      context 'when the given email address is not found' do
        let(:options) { { email: '404@example.com' } }

        it 'exits with an error message indicating that no user was found' do
          expect { cli.invoke(:delete, nil, options) }.to output(
            a_string_including('No user with such email')
          ).to_stdout
            .and raise_error(SystemExit)
        end
      end
    end
  end

  describe '#approve' do
    let(:total_users) { 10 }

    before do
      Form::AdminSettings.new(registrations_mode: 'approved').save
      Fabricate.times(total_users, :user)
    end

    context 'with --all option' do
      it 'approves all pending registrations' do
        cli.invoke(:approve, nil, all: true)

        expect(User.pluck(:approved).all?(true)).to be(true)
      end
    end

    context 'with --number option' do
      context 'when the number is positive' do
        let(:options) { { number: 3 } }

        it 'approves the earliest n pending registrations' do
          cli.invoke(:approve, nil, options)

          n_earliest_pending_registrations = User.order(created_at: :asc).first(options[:number])

          expect(n_earliest_pending_registrations.all?(&:approved?)).to be(true)
        end

        it 'does not approve the remaining pending registrations' do
          cli.invoke(:approve, nil, options)

          pending_registrations = User.order(created_at: :asc).last(total_users - options[:number])

          expect(pending_registrations.all?(&:approved?)).to be(false)
        end
      end

      context 'when the number is negative' do
        it 'exits with an error message indicating that the number must be positive' do
          expect { cli.invoke(:approve, nil, number: -1) }.to output(
            a_string_including('Number must be positive')
          ).to_stdout
            .and raise_error(SystemExit)
        end
      end

      context 'when the given number is greater than the number of users' do
        let(:options) { { number: total_users * 2 } }

        it 'approves all users' do
          cli.invoke(:approve, nil, options)

          expect(User.pluck(:approved).all?(true)).to be(true)
        end

        it 'does not raise any error' do
          expect { cli.invoke(:approve, nil, options) }
            .to_not raise_error
        end
      end
    end

    context 'with username argument' do
      context 'when the given username is found' do
        let(:user) { User.last }
        let(:arguments) { [user.account.username] }

        it 'approves the specified user successfully' do
          cli.invoke(:approve, arguments)

          expect(user.reload.approved?).to be(true)
        end
      end

      context 'when the given username is not found' do
        let(:arguments) { ['non_existent_username'] }

        it 'exits with an error message indicating that no such account was found' do
          expect { cli.invoke(:approve, arguments) }.to output(
            a_string_including('No such account')
          ).to_stdout
            .and raise_error(SystemExit)
        end
      end
    end
  end

  describe '#follow' do
    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'exits with an error message indicating that no account with the given username was found' do
        expect { cli.invoke(:follow, arguments) }.to output(
          a_string_including('No such account')
        ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when the given username is found' do
      let!(:target_account)   { Fabricate(:account) }
      let!(:follower_bob)     { Fabricate(:account, username: 'bob') }
      let!(:follower_rony)    { Fabricate(:account, username: 'rony') }
      let!(:follower_charles) { Fabricate(:account, username: 'charles') }
      let(:follow_service)    { instance_double(FollowService, call: nil) }
      let(:scope)             { Account.local.without_suspended }

      before do
        allow(cli).to receive(:parallelize_with_progress).and_yield(follower_bob)
                                                         .and_yield(follower_rony)
                                                         .and_yield(follower_charles)
                                                         .and_return([3, nil])
        allow(FollowService).to receive(:new).and_return(follow_service)
      end

      it 'makes all local accounts follow the target account' do
        cli.follow(target_account.username)

        expect(cli).to have_received(:parallelize_with_progress).with(scope).once
        expect(follow_service).to have_received(:call).with(follower_bob, target_account, any_args).once
        expect(follow_service).to have_received(:call).with(follower_rony, target_account, any_args).once
        expect(follow_service).to have_received(:call).with(follower_charles, target_account, any_args).once
      end

      it 'displays a successful message' do
        expect { cli.follow(target_account.username) }.to output(
          a_string_including('OK, followed target from 3 accounts')
        ).to_stdout
      end
    end
  end

  describe '#unfollow' do
    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'exits with an error message indicating that no account with the given username was found' do
        expect { cli.invoke(:unfollow, arguments) }.to output(
          a_string_including('No such account')
        ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when the given username is found' do
      let!(:target_account)  { Fabricate(:account) }
      let!(:follower_chris)  { Fabricate(:account, username: 'chris') }
      let!(:follower_rambo)  { Fabricate(:account, username: 'rambo') }
      let!(:follower_ana)    { Fabricate(:account, username: 'ana') }
      let(:unfollow_service) { instance_double(UnfollowService, call: nil) }
      let(:scope)            { target_account.followers.local }

      before do
        accounts = [follower_chris, follower_rambo, follower_ana]
        accounts.each { |account| target_account.follow!(account) }
        allow(cli).to receive(:parallelize_with_progress).and_yield(follower_chris)
                                                         .and_yield(follower_rambo)
                                                         .and_yield(follower_ana)
                                                         .and_return([3, nil])
        allow(UnfollowService).to receive(:new).and_return(unfollow_service)
      end

      it 'makes all local accounts unfollow the target account' do
        cli.unfollow(target_account.username)

        expect(cli).to have_received(:parallelize_with_progress).with(scope).once
        expect(unfollow_service).to have_received(:call).with(follower_chris, target_account).once
        expect(unfollow_service).to have_received(:call).with(follower_rambo, target_account).once
        expect(unfollow_service).to have_received(:call).with(follower_ana, target_account).once
      end

      it 'displays a successful message' do
        expect { cli.unfollow(target_account.username) }.to output(
          a_string_including('OK, unfollowed target from 3 accounts')
        ).to_stdout
      end
    end
  end

  describe '#backup' do
    context 'when the given username is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'exits with an error message indicating that there is no such account' do
        expect { cli.invoke(:backup, arguments) }.to output(
          a_string_including('No user with such username')
        ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when the given username is found' do
      let(:account) { Fabricate(:account) }
      let(:user) { account.user }
      let(:arguments) { [account.username] }

      it 'creates a new backup for the specified user' do
        expect { cli.invoke(:backup, arguments) }.to change { user.backups.count }.by(1)
      end

      it 'creates a backup job' do
        allow(BackupWorker).to receive(:perform_async)

        cli.invoke(:backup, arguments)
        latest_backup = user.backups.last

        expect(BackupWorker).to have_received(:perform_async).with(latest_backup.id).once
      end

      it 'displays a successful message' do
        expect { cli.invoke(:backup, arguments) }.to output(
          a_string_including('OK')
        ).to_stdout
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
        expect { cli.refresh }.to output(
          a_string_including('Refreshed 2 accounts')
        ).to_stdout
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
          expect { cli.refresh }.to output(
            a_string_including('Refreshed 2 accounts (DRY RUN)')
          ).to_stdout
        end
      end
    end

    context 'with a list of accts' do
      let!(:account_example_com_a) { Fabricate(:account, domain: 'example.com') }
      let!(:account_example_com_b) { Fabricate(:account, domain: 'example.com') }
      let!(:account_example_net)   { Fabricate(:account, domain: 'example.net') }
      let(:arguments)              { [account_example_com_a.acct, account_example_com_b.acct] }

      before do
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
            .to output(
              a_string_including("Account failed: #{account_example_com_a.username}@#{account_example_com_a.domain}")
            ).to_stdout
        end
      end

      context 'when a specified account is not found' do
        it 'exits with an error message' do
          allow(Account).to receive(:find_remote).with(account_example_com_b.username, account_example_com_b.domain).and_return(nil)

          expect { cli.refresh(*arguments) }.to output(
            a_string_including('No such account')
          ).to_stdout
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
        expect { cli.refresh }.to output(
          a_string_including('No account(s) given')
        ).to_stdout
          .and raise_error(SystemExit)
      end
    end
  end

  describe '#rotate' do
    context 'when neither username nor --all option are given' do
      it 'exits with an error message' do
        expect { cli.rotate }.to output(
          a_string_including('No account(s) given')
        ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when a username is given' do
      let(:account) { Fabricate(:account) }

      it 'correctly rotates keys for the specified account' do
        old_private_key = account.private_key
        old_public_key = account.public_key

        cli.rotate(account.username)
        account.reload

        expect(account.private_key).to_not eq(old_private_key)
        expect(account.public_key).to_not eq(old_public_key)
      end

      it 'broadcasts the new keys for the specified account' do
        allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_in)

        cli.rotate(account.username)

        expect(ActivityPub::UpdateDistributionWorker).to have_received(:perform_in).with(anything, account.id, anything).once
      end

      context 'when the given username is not found' do
        it 'exits with an error message when the specified username is not found' do
          expect { cli.rotate('non_existent_username') }.to output(
            a_string_including('No such account')
          ).to_stdout
            .and raise_error(SystemExit)
        end
      end
    end

    context 'when --all option is provided' do
      let(:accounts) { Fabricate.times(3, :account) }
      let(:options)  { { all: true } }

      before do
        allow(Account).to receive(:local).and_return(Account.where(id: accounts.map(&:id)))
        cli.options = { all: true }
      end

      it 'correctly rotates keys for all local accounts' do
        old_private_keys = accounts.map(&:private_key)
        old_public_keys = accounts.map(&:public_key)

        cli.rotate
        accounts.each(&:reload)

        expect(accounts.map(&:private_key)).to_not eq(old_private_keys)
        expect(accounts.map(&:public_key)).to_not eq(old_public_keys)
      end

      it 'broadcasts the new keys for each account' do
        allow(ActivityPub::UpdateDistributionWorker).to receive(:perform_in)

        cli.rotate

        accounts.each do |account|
          expect(ActivityPub::UpdateDistributionWorker).to have_received(:perform_in).with(anything, account.id, anything).once
        end
      end
    end
  end
end
