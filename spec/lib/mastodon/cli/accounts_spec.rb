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
end
