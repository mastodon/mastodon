# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/accounts_cli'

RSpec.describe Mastodon::AccountsCLI do
  let(:cli) { described_class.new }

  describe '#create' do
    shared_examples 'a new user with given email address and username' do
      it 'creates a new user with the correct email address' do
        cli.invoke(:create, arguments, options)

        user = User.find_by(email: options[:email])

        expect(user).to be_present
      end

      it 'creates a new account with the correct username' do
        cli.invoke(:create, arguments, options)

        account = Account.find_by(username: 'tootctl_username')

        expect(account).to be_present
      end

      it "returns OK and new user's password" do
        allow(SecureRandom).to receive(:hex).and_return('test_password')

        expect { cli.invoke(:create, arguments, options) }
          .to output(
            a_string_including("OK\nNew password: test_password")
          ).to_stdout
      end
    end

    context 'when required USERNAME and --email are provided' do
      let(:arguments) { ['tootctl_username'] }

      context 'with USERNAME and --email only' do
        let(:options) { { email: 'tootctl@example.com' } }

        include_examples 'a new user with given email address and username'

        context 'with invalid --email value' do
          let(:options) { { email: 'invalid' } }

          it 'returns an error message' do
            expect { cli.invoke(:create, arguments, options) }
              .to output(
                a_string_including('Failure/Error: email')
              ).to_stdout
              .and raise_error(SystemExit)
          end
        end
      end

      context 'with --confirmed option' do
        let(:options) { { email: 'tootctl@example.com', confirmed: true } }

        include_examples 'a new user with given email address and username'

        it 'creates a new confirmed user' do
          cli.invoke(:create, arguments, options)

          user = User.find_by(email: options[:email])

          expect(user.confirmed?).to be(true)
        end
      end

      context 'with --approve option' do
        let(:options) { { email: 'tootctl@example.com', approve: true } }

        before { Form::AdminSettings.new(registrations_mode: 'approved').save }

        include_examples 'a new user with given email address and username'

        it 'creates a new approved user' do
          cli.invoke(:create, arguments, options)

          user = User.find_by(email: options[:email])

          expect(user.approved?).to be(true)
        end
      end

      context 'with --role option' do
        context 'when role exists' do
          let(:default_role) { Fabricate(:user_role) }
          let(:options) { { email: 'tootctl@example.com', role: default_role.name } }

          include_examples 'a new user with given email address and username'

          it 'creates a new user with given role' do
            cli.invoke(:create, arguments, options)

            user = User.find_by(email: options[:email])
            role = user.role

            expect(role.name).to eq(default_role.name)
          end
        end

        context 'when role does not exist' do
          let(:options) { { email: 'tootctl@example.com', role: '404' } }

          it 'returns error informing the given role name was not found' do
            expect { cli.invoke(:create, arguments, options) }
              .to output(
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

          before { Fabricate(:account, username: 'tootctl_username', user: user) }

          it 'returns username already in use error message' do
            expect { cli.invoke(:create, arguments, options) }
              .to output(
                a_string_including("The chosen username is currently in use\nUse --force to reattach it anyway and delete the other user")
              ).to_stdout
          end

          context 'with --force option' do
            let(:options) { { email: 'tootctl_new@example.com', reattach: true, force: true } }

            it 'reattaches the account and deletes the other user' do
              cli.invoke(:create, arguments, options)

              user = Account.find_by(username: 'tootctl_username').user

              expect(user.email).to eq(options[:email])
            end
          end
        end

        context "when account's user is not present" do
          let(:options) { { email: 'tootctl@example.com', reattach: true } }

          before { Fabricate(:account, username: 'tootctl_username', user: nil) }

          include_examples 'a new user with given email address and username'
        end
      end
    end

    context 'when required --email option is not provided' do
      let(:arguments) { ['tootctl_username'] }

      it 'raise Thor::RequiredArgumentMissingError' do
        expect { cli.invoke(:create, arguments) }
          .to raise_error(Thor::RequiredArgumentMissingError)
      end
    end
  end

  describe '#modify' do
    context 'when given username is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'returns an error message' do
        expect { cli.invoke(:modify, arguments) }
          .to output(
            a_string_including('No user with such username')
          ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when given username is found' do
      let(:user) { Fabricate(:user) }
      let(:arguments) { [user.account.username] }

      context 'when no option is provided' do
        it 'returns successfull message' do
          expect { cli.invoke(:modify, arguments) }
            .to output(
              a_string_including('OK')
            ).to_stdout
        end

        it 'does not modify the user' do
          cli.invoke(:modify, arguments)

          user_after_modify = User.find_by(email: user.email)

          expect(user).to eq(user_after_modify)
        end
      end

      context 'with --role option' do
        context 'when given role is not found' do
          let(:options) { { role: '404' } }

          it 'returns an error message' do
            expect { cli.invoke(:modify, arguments, options) }
              .to output(
                a_string_including('Cannot find user role with that name')
              ).to_stdout
              .and raise_error(SystemExit)
          end
        end

        context 'when given role is found' do
          let(:default_role) { Fabricate(:user_role) }
          let(:options) { { role: default_role.name } }

          it "updates the user's role" do
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

        it "removes user's role successfully" do
          cli.invoke(:modify, arguments, options)

          role = user.reload.role

          expect(role.name).to be_empty
        end
      end

      context 'with --email option' do
        let(:user) { Fabricate(:user, email: 'old_email@email.com') }
        let(:options) { { email: 'new_email@email.com' } }

        it "sets 'unconfirmed_email' with given email adress" do
          cli.invoke(:modify, arguments, options)

          expect(user.reload.unconfirmed_email).to eq(options[:email])
        end

        it 'does not update original email address' do
          cli.invoke(:modify, arguments, options)

          expect(user.reload.email).to eq('old_email@email.com')
        end

        context 'with --confirm option' do
          let(:user) { Fabricate(:user, email: 'old_email@email.com', confirmed_at: nil) }
          let(:options) { { email: 'new_email@email.com', confirm: true } }

          it "updates the user's email address" do
            cli.invoke(:modify, arguments, options)

            expect(user.reload.email).to eq(options[:email])
          end

          it "set user's email address as confirmed" do
            cli.invoke(:modify, arguments, options)

            expect(user.reload.confirmed?).to be(true)
          end
        end
      end

      context 'with --confirm option' do
        let(:user) { Fabricate(:user, confirmed_at: nil) }
        let(:options) { { confirm: true } }

        it "confirms user's email address" do
          cli.invoke(:modify, arguments, options)

          expect(user.reload.confirmed?).to be(true)
        end
      end

      context 'with --approve option' do
        let(:user) { Fabricate(:user, approved: false) }
        let(:options) { { approve: true } }

        it 'approves user' do
          cli.invoke(:modify, arguments, options)

          expect(user.reload.approved?).to be(true)
        end
      end

      context 'with --disable option' do
        let(:user) { Fabricate(:user, disabled: false) }
        let(:options) { { disable: true } }

        it 'disables the user' do
          cli.invoke(:modify, arguments, options)

          expect(user.reload.disabled).to be(true)
        end
      end

      context 'with --enable option' do
        let(:user) { Fabricate(:user, disabled: true) }
        let(:options) { { enable: true } }

        it 'enables the user' do
          cli.invoke(:modify, arguments, options)

          expect(user.reload.disabled).to be(false)
        end
      end

      context 'with --reset-password option' do
        let(:options) { { reset_password: true } }

        it "outputs new user's password" do
          allow(SecureRandom).to receive(:hex).and_return('new_password')

          expect { cli.invoke(:modify, arguments, options) }
            .to output(
              a_string_including('new_password')
            ).to_stdout
        end
      end

      context 'with --disable-2fa option' do
        let(:user) { Fabricate(:user, otp_required_for_login: true) }
        let(:options) { { disable_2fa: true } }

        it "sets 'otp_required_for_login' to false" do
          cli.invoke(:modify, arguments, options)

          expect(user.reload.otp_required_for_login).to be(false)
        end
      end

      context 'when provided data is invalid' do
        let(:user) { Fabricate(:user) }
        let(:options) { { email: 'invalid' } }

        it 'returns an error message' do
          expect { cli.invoke(:modify, arguments, options) }
            .to output(
              a_string_including('Failure/Error: email')
            ).to_stdout
            .and raise_error(SystemExit)
        end
      end
    end
  end

  describe '#delete' do
    context 'when both USERNAME and --email are provided' do
      let(:user) { Fabricate(:user) }
      let(:arguments) { [user.account.username] }
      let(:options) { { email: user.email } }

      it 'returns an error message' do
        expect { cli.invoke(:delete, arguments, options) }
          .to output(
            a_string_including('Use username or --email, not both')
          ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when neither USERNAME nor --email are provided' do
      it 'returns an error message' do
        expect { cli.invoke(:delete) }
          .to output(
            a_string_including('No username provided')
          ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when USERNAME is provided' do
      let(:user) { Fabricate(:user) }
      let(:arguments) { [user.account.username] }

      it 'deletes user successfully' do
        cli.invoke(:delete, arguments)

        deleleted_user = Account.find_local(user.account.username)&.user

        expect(deleleted_user).to be_nil
      end

      context 'with --dry-run option' do
        let(:options) { { dry_run: true } }

        it 'does not delete the user' do
          cli.invoke(:delete, arguments, options)

          expect(user.reload).to be_present
        end

        it 'outputs (DRY RUN) message' do
          expect { cli.invoke(:delete, arguments, options) }
            .to output(
              a_string_including('OK (DRY RUN)')
            ).to_stdout
        end
      end

      context 'when given USERNAME is not found' do
        let(:arguments) { ['non_exitent_username'] }

        it 'returns an error message' do
          expect { cli.invoke(:delete, arguments) }
            .to output(
              a_string_including('No user with such username')
            ).to_stdout
            .and raise_error(SystemExit)
        end
      end
    end

    context 'when --email is provided' do
      let(:user) { Fabricate(:user) }
      let(:options) { { email: user.email } }

      it 'deletes user successfully' do
        cli.invoke(:delete, nil, options)

        deleleted_user = Account.find_local(user.account.username)&.user

        expect(deleleted_user).to be_nil
      end

      context 'with --dry-run option' do
        let(:options) { { email: user.email, dry_run: true } }

        it 'does not delete the user' do
          cli.invoke(:delete, nil, options)

          expect(user.reload).to be_present
        end

        it 'outputs (DRY RUN) message' do
          expect { cli.invoke(:delete, nil, options) }
            .to output(
              a_string_including('OK (DRY RUN)')
            ).to_stdout
        end
      end

      context 'when given email address is not found' do
        let(:options) { { email: '404@404.com' } }

        it 'returns an error message' do
          expect { cli.invoke(:delete, nil, options) }
            .to output(
              a_string_including('No user with such email')
            ).to_stdout
            .and raise_error(SystemExit)
        end
      end
    end
  end

  describe '#approve' do
    context 'with --all option' do
      let(:options) { { all: true } }

      before do
        Form::AdminSettings.new(registrations_mode: 'approved').save
        Fabricate.times(5, :user)
      end

      it 'approves all pending registrations' do
        cli.invoke(:approve, nil, options)

        expect(User.pluck(:approved).all?(true)).to be(true)
      end
    end

    context 'with --number option' do
      context 'when number is positive' do
        let(:options) { { number: 3 } }
        let(:total_users) { 10 }

        before do
          Form::AdminSettings.new(registrations_mode: 'approved').save
          Fabricate.times(total_users, :user)
        end

        it 'approves the N earliest pending registrations' do
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
        let(:options) { { number: -1 } }

        it 'returns an error message' do
          expect { cli.invoke(:approve, nil, options) }
            .to output(
              a_string_including('Number must be positive')
            ).to_stdout
            .and raise_error(SystemExit)
        end
      end

      context 'when number is greater than the number of users' do
        let(:total_users) { 10 }
        let(:options) { { number: total_users * 2 } }

        before do
          Form::AdminSettings.new(registrations_mode: 'approved').save
          Fabricate.times(total_users, :user)
        end

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

    context 'with USERNAME' do
      context 'when given USERNAME is found' do
        let(:user) { Fabricate(:user) }
        let(:arguments) { [user.account.username] }

        before { user.update(approved: false) }

        it 'approves user successfully' do
          cli.invoke(:approve, arguments)

          expect(user.reload.approved?).to be(true)
        end
      end

      context 'when given USERNAME is not found' do
        let(:arguments) { ['non_existent_username'] }

        it 'returns an error message' do
          expect { cli.invoke(:approve, arguments) }
            .to output(
              a_string_including('No such account')
            ).to_stdout
            .and raise_error(SystemExit)
        end
      end
    end
  end

  describe '#backup' do
    context 'when given USERNAME is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'returns an error message' do
        expect { cli.invoke(:backup, arguments) }
          .to output(
            a_string_including('No user with such username')
          ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when given USERNAME is found' do
      let(:user) { Fabricate(:user) }
      let(:arguments) { [user.account.username] }

      it 'creates a backup job' do
        allow(BackupWorker).to receive(:perform_async).once

        cli.invoke(:backup, arguments)

        expect(BackupWorker).to have_received(:perform_async).once
      end

      it 'outputs a success message' do
        expect { cli.invoke(:backup, arguments) }
          .to output(
            a_string_including('OK')
          ).to_stdout
      end
    end
  end

  describe '#follow' do
    context 'when provided USERNAME is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'returns an error message' do
        expect { cli.invoke(:follow, arguments) }
          .to output(
            a_string_including('No such account')
          ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when provided USERNAME is found' do
      let(:target_account) { Fabricate(:account) }
      let!(:accounts) { Fabricate.times(10, :account) }
      let(:arguments) { [target_account.username] }

      before { allow_any_instance_of(Mastodon::CLIHelper).to receive(:reset_connection_pools!) }

      it 'all local accounts follow specified account successfully' do
        cli.invoke(:follow, arguments)

        result = accounts.all? { |account| target_account.followed_by?(account) }

        expect(result).to be(true)
      end
    end
  end

  describe '#unfollow' do
    context 'when provided USERNAME is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'returns an error message' do
        expect { cli.invoke(:unfollow, arguments) }
          .to output(
            a_string_including('No such account')
          ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when provided USERNAME is found' do
      let(:target_account) { Fabricate(:account) }
      let(:accounts) { Fabricate.times(5, :account) }
      let(:arguments) { [target_account.username] }

      before do
        accounts.each { |account| target_account.follow!(account) }

        allow_any_instance_of(Mastodon::CLIHelper).to receive(:reset_connection_pools!)
      end

      it 'all local accounts unfollow specified account successfully' do
        cli.invoke(:unfollow, arguments)

        result = accounts.all? { |account| target_account.followed_by?(account) }

        expect(result).to be(false)
      end
    end
  end

  describe '#reset_relationships' do
    context 'when no option is provided' do
      let(:target_account) { Fabricate(:account) }
      let(:arguments) { [target_account.username] }

      it 'returns an error message' do
        expect { cli.invoke(:reset_relationships, arguments) }
          .to output(
            a_string_including('Please specify either --follows or --followers, or both')
          ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when provided USERNAME is not found' do
      let(:options) { { follows: true } }
      let(:arguments) { ['non_existent_username'] }

      it 'returns an error message' do
        expect { cli.invoke(:reset_relationships, arguments, options) }
          .to output(
            a_string_including('No such account')
          ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when provided USERNAME is found' do
      context 'with --follows option' do
        let(:target_account) { Fabricate(:account) }
        let(:arguments) { [target_account.username] }
        let(:options) { { follows: true } }
        let(:total_relationships) { 10 }

        before do
          accounts = Fabricate.times(total_relationships, :account)
          accounts.each { |account| target_account.follow!(account) }
        end

        it 'resets all "following" relationships from target_account' do
          cli.invoke(:reset_relationships, arguments, options)

          expect(target_account.reload.following).to be_empty
        end

        it 'calls BootstrapTimelineWorker once' do
          allow(BootstrapTimelineWorker).to receive(:perform_async).once

          cli.invoke(:reset_relationships, arguments, options)

          expect(BootstrapTimelineWorker).to have_received(:perform_async)
        end

        it 'outputs success message' do
          expect { cli.invoke(:reset_relationships, arguments, options) }
            .to output(
              a_string_including("Processed #{total_relationships} relationships")
            ).to_stdout
        end
      end

      context 'with --followers option' do
        let(:target_account) { Fabricate(:account) }
        let(:arguments) { [target_account.username] }
        let(:options) { { followers: true } }
        let(:total_relationships) { 10 }

        before do
          accounts = Fabricate.times(total_relationships, :account)
          accounts.each { |account| account.follow!(target_account) }
        end

        it 'resets all "followers" relationships' do
          cli.invoke(:reset_relationships, arguments, options)

          expect(target_account.reload.followers).to be_empty
        end

        it 'outputs success message' do
          expect { cli.invoke(:reset_relationships, arguments, options) }
            .to output(
              a_string_including("Processed #{total_relationships} relationships")
            ).to_stdout
        end
      end

      context 'with --follows and --followers options' do
        let(:target_account) { Fabricate(:account) }
        let(:arguments) { [target_account.username] }
        let(:options) { { followers: true, follows: true } }
        let(:total_relationships) { 16 }

        before do
          accounts = Fabricate.times(total_relationships, :account)
          accounts.first(8).each { |account| account.follow!(target_account) }
          accounts.last(8).each { |account| target_account.follow!(account) }
        end

        it 'resets all "followers" relationships' do
          cli.invoke(:reset_relationships, arguments, options)

          expect(target_account.reload.followers).to be_empty
        end

        it 'resets all "following" relationships' do
          cli.invoke(:reset_relationships, arguments, options)

          expect(target_account.reload.following).to be_empty
        end

        it 'calls BootstrapTimelineWorker once' do
          allow(BootstrapTimelineWorker).to receive(:perform_async).once

          cli.invoke(:reset_relationships, arguments, options)

          expect(BootstrapTimelineWorker).to have_received(:perform_async)
        end

        it 'outputs success message' do
          expect { cli.invoke(:reset_relationships, arguments, options) }
            .to output(
              a_string_including("Processed #{total_relationships} relationships")
            ).to_stdout
        end
      end
    end
  end

  describe '#rotate' do
    context 'when neither USERNAME nor --all option are provided' do
      it 'returns an error message' do
        expect { cli.invoke(:rotate, nil, nil) }
          .to output(
            a_string_including('No account(s) given')
          ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when provided USERNAME is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'returns an error message' do
        expect { cli.invoke(:rotate, arguments) }
          .to output(
            a_string_including('No such account')
          ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when USERNAME is provided' do
      let(:account) { Fabricate(:account) }
      let(:arguments) { [account.username] }

      it 'rotates keys for the specified account correctly' do
        old_private_key = account.private_key
        old_public_key = account.public_key

        cli.invoke(:rotate, arguments)
        account.reload

        expect(account.private_key).to_not eq(old_private_key)
        expect(account.public_key).to_not eq(old_public_key)
      end
    end

    context 'when --all option is provided' do
      let(:accounts) { Fabricate.times(3, :account) }

      before { allow(Account).to receive(:local).and_return(Account.where(id: accounts.map(&:id))) }

      it 'rotates keys for all local accounts' do
        allow(cli).to receive(:rotate_keys_for_account).exactly(3).times

        cli.options = { all: true }
        cli.rotate

        expect(cli).to have_received(:rotate_keys_for_account).exactly(3).times
      end
    end
  end

  describe '#merge' do
    context 'when "from_account" is not found' do
      let(:to_account) { Fabricate(:account, domain: 'example.com') }
      let(:arguments) { ['non_existent_username@domain.com', "#{to_account.username}@#{to_account.domain}"] }

      it 'returns an error message' do
        expect { cli.invoke(:merge, arguments) }
          .to output(
            a_string_including("No such account (#{arguments.first})")
          ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when "from_account" is local' do
      let(:from_account) { Fabricate(:account, domain: nil) }
      let(:to_account) { Fabricate(:account, domain: 'example.com') }
      let(:arguments) { [from_account.username, "#{to_account.username}@#{to_account.domain}"] }

      it 'returns an error message' do
        expect { cli.invoke(:merge, arguments) }
          .to output(
            a_string_including("No such account (#{arguments.first})")
          ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when "to_account" is not found' do
      let(:from_account) { Fabricate(:account, domain: 'example.com') }
      let(:arguments) { ["#{from_account.username}@#{from_account.domain}", 'non_existent_username'] }

      it 'returns an error message' do
        expect { cli.invoke(:merge, arguments) }
          .to output(
            a_string_including("No such account (#{arguments.last})")
          ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when "to_account" is local' do
      let(:from_account) { Fabricate(:account, domain: 'example.com') }
      let(:to_account) { Fabricate(:account, domain: nil) }
      let(:arguments) do
        ["#{from_account.username}@#{from_account.domain}", "#{to_account.username}@#{to_account.domain}"]
      end

      it 'returns an error message' do
        expect { cli.invoke(:merge, arguments) }
          .to output(
            a_string_including("No such account (#{arguments.last})")
          ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when "from_account" and "to_account" public keys do not match' do
      let(:from_account) { instance_double(Account, username: 'bob', domain: 'example1.com', local?: false) }
      let(:to_account) { instance_double(Account, username: 'bob', domain: 'example2.com', local?: false) }

      let(:arguments) do
        ["#{from_account.username}@#{from_account.domain}", "#{to_account.username}@#{to_account.domain}"]
      end

      before do
        allow(Account).to receive(:find_remote).with(from_account.username, from_account.domain).and_return(from_account)
        allow(Account).to receive(:find_remote).with(to_account.username, to_account.domain).and_return(to_account)
        allow(from_account).to receive(:public_key).and_return('from_account')
        allow(to_account).to receive(:public_key).and_return('to_account')
      end

      it 'returns a warning message' do
        expect { cli.invoke(:merge, arguments) }
          .to output(
            a_string_including("Accounts don't have the same public key, might not be duplicates!\nOverride with --force")
          ).to_stdout
          .and raise_error(SystemExit)
      end

      context 'with --force option' do
        let(:options) { { force: true } }

        before do
          allow(to_account).to receive(:merge_with!).with(from_account)
          allow(from_account).to receive(:destroy)
        end

        it 'merges "from_account" into "to_account"' do
          cli.invoke(:merge, arguments, options)

          expect(to_account).to have_received(:merge_with!).with(from_account)
        end

        it 'deletes "from_account"' do
          cli.invoke(:merge, arguments, options)

          expect(from_account).to have_received(:destroy)
        end
      end
    end

    context 'when "from_account" and "to_account" public keys match' do
      let(:from_account) { instance_double(Account, username: 'bob', domain: 'example1.com', local?: false) }
      let(:to_account) { instance_double(Account, username: 'bob', domain: 'example2.com', local?: false) }

      let(:arguments) do
        ["#{from_account.username}@#{from_account.domain}", "#{to_account.username}@#{to_account.domain}"]
      end

      before do
        allow(Account).to receive(:find_remote).with(from_account.username, from_account.domain).and_return(from_account)
        allow(Account).to receive(:find_remote).with(to_account.username, to_account.domain).and_return(to_account)
        allow(from_account).to receive(:public_key).and_return('pub_key')
        allow(to_account).to receive(:public_key).and_return('pub_key')
      end

      it 'merges "from_account" into "to_account"' do
        allow(to_account).to receive(:merge_with!).with(from_account)
        allow(from_account).to receive(:destroy)

        cli.invoke(:merge, arguments)

        expect(to_account).to have_received(:merge_with!).with(from_account)
      end

      it 'deletes "from_account"' do
        allow(to_account).to receive(:merge_with!).with(from_account)
        allow(from_account).to receive(:destroy)

        cli.invoke(:merge, arguments)

        expect(from_account).to have_received(:destroy)
      end
    end
  end

  describe '#migrate' do
    it 'exits with an error message if both --replay and --target options are provided' do
      target_account = Fabricate(:account, domain: 'example.com')
      options = { replay: true, target: "#{target_account.username}@example.com" }
      arguments = [target_account.username]

      expect { cli.invoke(:migrate, arguments, options) }
        .to output(
          a_string_including('Use --replay or --target, not both')
        ).to_stdout
        .and raise_error(SystemExit)
    end

    it 'exits with an error message if option is provided' do
      target_account = Fabricate(:account, domain: 'example.com')
      arguments = [target_account.username]

      expect { cli.invoke(:migrate, arguments, {}) }
        .to output(
          a_string_including('Use either --replay or --target')
        ).to_stdout
        .and raise_error(SystemExit)
    end

    it 'exits with an error message if provided USERNAME is not found' do
      arguments = ['non_existent_username']
      options = { replay: true }

      expect { cli.invoke(:migrate, arguments, options) }
        .to output(
          a_string_including("No such account: #{arguments.first}")
        ).to_stdout
        .and raise_error(SystemExit)
    end

    context 'with --replay option' do
      let(:source_account) { Fabricate(:account) }
      let(:arguments) { [source_account.username] }
      let(:options) { { replay: true } }

      context 'when given account has no previous migrations' do
        it 'exits with an error message' do
          expect { cli.invoke(:migrate, arguments, options) }
            .to output(
              a_string_including('The specified account has not performed any migration')
            ).to_stdout
            .and raise_error(SystemExit)
        end
      end

      context 'when account has a previous migration' do
        let(:target_account) { Fabricate(:account, domain: 'example.com') }
        let(:move_service) { instance_double(MoveService) }
        let(:migration) { instance_double(AccountMigration, target_account: target_account, target_account_id: target_account.id) }

        before do
          allow(Account).to receive(:find_local).with(source_account.username).and_return(source_account)
          allow(source_account).to receive(:moved_to_account_id).and_return(target_account.id)
          allow(source_account.migrations).to receive(:last).and_return(migration)

          allow(MoveService).to receive(:new).and_return(move_service)
          allow(move_service).to receive(:call).with(migration)
        end

        it 'calls the MoveService for the last migration' do
          cli.invoke(:migrate, arguments, options)

          expect(move_service).to have_received(:call).with(migration)
        end

        it 'migrates account successfully' do
          expect { cli.invoke(:migrate, arguments, options) }
            .to output(
              a_string_including("OK, migrated #{source_account.acct} to #{target_account.acct}")
            ).to_stdout
        end

        context 'when specified account is redirecting to a different target account' do
          it 'exits with an error message' do
            allow(source_account).to receive(:moved_to_account_id).and_return(-1)

            expect { cli.invoke(:migrate, arguments, options) }
              .to output(
                a_string_including('The specified account is not redirecting to its last migration target. Use --force if you want to replay the migration anyway')
              ).to_stdout
              .and raise_error(SystemExit)
          end
        end

        context 'with --force option' do
          let(:options) { { replay: true, force: true } }

          before { allow(source_account).to receive(:moved_to_account_id).and_return(-1) }

          it 'calls the MoveService for the last migration' do
            cli.invoke(:migrate, arguments, options)

            expect(move_service).to have_received(:call).with(migration)
          end

          it 'migrates account successfully' do
            expect { cli.invoke(:migrate, arguments, options) }
              .to output(
                a_string_including("OK, migrated #{source_account.acct} to #{target_account.acct}")
              ).to_stdout
          end
        end
      end
    end

    context 'with --target option' do
      let(:source_account) { Fabricate(:account) }
      let(:arguments) { [source_account.username] }
      let(:resolve_account_service) { instance_double(ResolveAccountService) }

      it 'exits with an error message if specified target account is not found' do
        options = { target: 'non_existent@404.com' }

        allow(ResolveAccountService).to receive(:new).and_return(resolve_account_service)
        allow(resolve_account_service).to receive(:call).and_return(nil)

        expect { cli.invoke(:migrate, arguments, options) }
          .to output(
            a_string_including("The specified target account could not be found: #{options[:target]}")
          ).to_stdout
          .and raise_error(SystemExit)
      end

      context 'when target account exists' do
        let(:target_account) { Fabricate(:account, username: 'target', domain: 'example.com') }
        let(:options) { { target: target_account.acct } }

        before do
          target_account.aliases.create!(acct: source_account.acct)

          allow(ResolveAccountService).to receive(:new).and_return(resolve_account_service)
          allow(resolve_account_service).to receive(:call).with(target_account.acct, any_args).and_return(target_account)
        end

        it 'creates a migration for the specified account with the target account' do
          cli.invoke(:migrate, arguments, options)

          last_migration = source_account.migrations.last

          expect(last_migration.acct).to eq(target_account.acct)
        end

        it 'displays success message' do
          expect { cli.invoke(:migrate, arguments, options) }
            .to output(
              a_string_including("OK, migrated #{source_account.acct} to #{target_account.acct}")
            ).to_stdout
        end
      end

      context 'when migration record is invalid' do
        let(:target_account) { Fabricate(:account, username: 'target', domain: 'example.com') }
        let(:options) { { target: target_account.acct } }

        before do
          allow(ResolveAccountService).to receive(:new).and_return(resolve_account_service)
          allow(resolve_account_service).to receive(:call).with(target_account.acct, any_args).and_return(target_account)
        end

        it 'exits with an error' do
          expect { cli.invoke(:migrate, arguments, options) }
            .to output(
              a_string_including('Error: Validation failed')
            ).to_stdout
            .and raise_error(SystemExit)
        end
      end

      context 'when specified account is redirecting to a different target account' do
        let(:target_account) { Fabricate(:account, domain: 'example.com') }
        let(:options) { { target: target_account.acct } }

        before do
          allow(Account).to receive(:find_local).with(source_account.username).and_return(source_account)
          allow(ResolveAccountService).to receive(:new).and_return(resolve_account_service)
          allow(resolve_account_service).to receive(:call).with(target_account.acct, any_args).and_return(target_account)
        end

        it 'exits with an error message' do
          allow(source_account).to receive(:moved_to_account_id).and_return(-1)

          expect { cli.invoke(:migrate, arguments, options) }
            .to output(
              a_string_including('The specified account is redirecting to a different target account. Use --force if you want to change the migration target')
            ).to_stdout
            .and raise_error(SystemExit)
        end
      end

      context 'with --target and --force options' do
        let(:target_account) { Fabricate(:account, domain: 'example.com') }
        let(:options) { { target: target_account.acct, force: true } }

        before do
          target_account.aliases.create!(acct: source_account.acct)

          allow(Account).to receive(:find_local).with(source_account.username).and_return(source_account)
          allow(ResolveAccountService).to receive(:new).and_return(resolve_account_service)
          allow(resolve_account_service).to receive(:call).with(target_account.acct, any_args).and_return(target_account)
        end

        it 'displays success message' do
          allow(source_account).to receive(:moved_to_account_id).and_return(-1)

          expect { cli.invoke(:migrate, arguments, options) }
            .to output(
              a_string_including("OK, migrated #{source_account.acct} to #{target_account.acct}")
            ).to_stdout
        end
      end
    end
  end

  describe '#fix_duplicates' do
    context 'when there are no duplicates' do
      it 'exits with no error' do
        expect { cli.invoke(:fix_duplicates) }
          .to_not raise_error
      end
    end

    context 'when there are duplicates' do
      let(:uri) { 'https://ap.example.com/users/foo' }

      before do
        Fabricate(:account, username: 'foo', domain: 'old.example.com', uri: uri)
        Fabricate(:account, username: 'foo', domain: 'new.example.com', uri: uri)

        stub_request(:get, 'https://quitter.no/avatar/7477-300-20160211190340.png').to_return(request_fixture('avatar.txt'))
        stub_request(:get, 'https://ap.example.com/.well-known/webfinger?resource=acct:foo@ap.example.com').to_return(request_fixture('activitypub-webfinger.txt'))
        stub_request(:get, 'https://ap.example.com/users/foo').to_return(request_fixture('activitypub-actor.txt'))
        stub_request(:get, %r{https://ap\.example\.com/users/foo/\w+}).to_return(status: 404)
      end

      it 'merges accounts' do
        cli.invoke(:fix_duplicates)

        expect(Account.where(uri: uri).count).to eq(1)
      end

      it 'displays duplicates for given URI' do
        expect { cli.invoke(:fix_duplicates) }
          .to output(
            a_string_including("Duplicates found for #{uri}")
          ).to_stdout
      end
    end

    context 'when an error is raised' do
      let(:fetch_remote_account_service) { instance_double(ActivityPub::FetchRemoteAccountService) }
      let(:uri) { 'https://ap.example.com/users/foo' }

      before do
        Fabricate(:account, username: 'foo', domain: 'old.example.com', uri: uri)
        Fabricate(:account, username: 'foo', domain: 'new.example.com', uri: uri)

        allow(ActivityPub::FetchRemoteAccountService).to receive(:new).and_return(fetch_remote_account_service)
      end

      it 'displays error message' do
        error_message = 'Uncaught error'
        allow(fetch_remote_account_service).to receive(:call).with(uri).and_raise(error_message)

        expect { cli.invoke(:fix_duplicates) }
          .to output(
            a_string_including("Error processing #{uri}: #{error_message}")
          ).to_stdout
      end
    end

    context 'with --dry-run option' do
      let(:fetch_remote_account_service) { instance_double(ActivityPub::FetchRemoteAccountService) }
      let(:uri) { 'https://ap.example.com/users/foo' }
      let(:options) { { dry_run: true } }

      before do
        Fabricate(:account, username: 'foo', domain: 'old.example.com', uri: uri)
        Fabricate(:account, username: 'foo', domain: 'new.example.com', uri: uri)

        allow(ActivityPub::FetchRemoteAccountService).to receive(:new).and_return(fetch_remote_account_service)
      end

      it 'does not call FetchRemoteAccountService' do
        allow(fetch_remote_account_service).to receive(:call).with(uri)

        cli.invoke(:fix_duplicates, nil, options)

        expect(fetch_remote_account_service).to_not have_received(:call).with(uri)
      end
    end
  end
end
