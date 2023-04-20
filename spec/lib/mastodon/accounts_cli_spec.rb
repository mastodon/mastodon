# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/accounts_cli'

RSpec.describe Mastodon::AccountsCLI do
  describe '#create' do
    context 'when required USERNAME and --email are provided' do
      let(:arguments) { ['tootctl_username'] }

      context 'with USERNAME and --email only' do
        let(:options) { { email: 'tootctl@example.com' } }

        it 'creates a new user with the correct email address' do
          described_class.new.invoke(:create, arguments, options)

          user = User.find_by(email: 'tootctl@example.com')

          expect(user).to be_present
        end

        it 'creates a new account with the correct username' do
          described_class.new.invoke(:create, arguments, options)

          account = Account.find_by(username: 'tootctl_username')

          expect(account).to be_present
        end

        it "returns OK and new user's password" do
          allow(SecureRandom).to receive(:hex).and_return('test_password')

          expect { described_class.new.invoke(:create, arguments, options) }
            .to output(
              a_string_including("OK\nNew password: test_password")
            ).to_stdout
        end
      end

      context 'with --confirmed option' do
        let(:options) { { email: 'tootctl@example.com', confirmed: true } }

        it 'creates a new confirmed user' do
          described_class.new.invoke(:create, arguments, options)

          user = User.find_by(email: options[:email])

          expect(user.confirmed?).to be(true)
        end
      end

      context 'with --approve option' do
        let(:options) { { email: 'tootctl@example.com', approve: true } }

        before { Form::AdminSettings.new(registrations_mode: 'approved').save }

        it 'creates a new approved user' do
          described_class.new.invoke(:create, arguments, options)

          user = User.find_by(email: options[:email])

          expect(user.approved?).to be(true)
        end
      end

      context 'with --role option' do
        context 'when role exists' do
          let(:options) { { email: 'tootctl@example.com', role: 'Owner' } }

          it 'creates a new user with given role' do
            described_class.new.invoke(:create, arguments, options)

            user = User.find_by(email: options[:email])
            role = user.role

            expect(role.name).to eq('Owner')
          end
        end

        context 'when role does not exist' do
          let(:options) { { email: 'tootctl@example.com', role: '404' } }

          it 'returns error informing the given role name was not found' do
            expect { described_class.new.invoke(:create, arguments, options) }
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
          let(:account) { Account.new(username: 'tootctl_username') }

          before { User.create(email: 'tootctl@example.com', password: '12345678', agreement: true, account: account) }

          it 'returns username already in use error message' do
            expect { described_class.new.invoke(:create, arguments, options) }
              .to output(
                a_string_including("The chosen username is currently in use\nUse --force to reattach it anyway and delete the other user")
              ).to_stdout
          end
        end

        context "when account's user is not present" do
          let(:options) { { email: 'tootctl@example.com', reattach: true } }

          before { Account.create(username: 'tootctl_username') }

          it 'creates a new user with the correct email address' do
            described_class.new.invoke(:create, arguments, options)

            user = User.find_by(email: 'tootctl@example.com')

            expect(user).to be_present
          end
        end
      end

      context 'with invalid --email value' do
        let(:options) { { email: 'invalid' } }

        it 'returns an error message' do
          expect { described_class.new.invoke(:create, arguments, options) }
            .to output(
              a_string_including('Failure/Error: email')
            ).to_stdout
            .and raise_error(SystemExit)
        end
      end
    end

    context 'when required --email option is not provided' do
      let(:arguments) { ['tootctl_username'] }

      it 'raise Thor::RequiredArgumentMissingError' do
        expect { described_class.new.invoke(:create, arguments) }
          .to raise_error(Thor::RequiredArgumentMissingError)
      end
    end
  end

  describe '#modify' do
    context 'when given username is not found' do
      let(:arguments) { ['non_existent_username'] }

      it 'returns an error message' do
        expect { described_class.new.invoke(:modify, arguments) }
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
          expect { described_class.new.invoke(:modify, arguments) }
            .to output(
              a_string_including('OK')
            ).to_stdout
        end

        it 'does not modify the user' do
          described_class.new.invoke(:modify, arguments)

          user_after_modify = User.find_by(email: user.email)

          expect(user).to eq(user_after_modify)
        end
      end

      context 'with --role option' do
        context 'when given role is not found' do
          let(:options) { { role: '404' } }

          it 'returns an error message' do
            expect { described_class.new.invoke(:modify, arguments, options) }
              .to output(
                a_string_including('Cannot find user role with that name')
              ).to_stdout
              .and raise_error(SystemExit)
          end
        end

        context 'when given role is found' do
          let(:options) { { role: 'Owner' } }

          it "updates the user's role" do
            described_class.new.invoke(:modify, arguments, options)

            role = user.reload.role

            expect(role.name).to eq('Owner')
          end
        end
      end

      context 'with --remove-role option' do
        let(:options) { { remove_role: true } }
        let(:role) { Fabricate(:user_role) }
        let(:user) { Fabricate(:user, role: role) }

        it "removes user's role successfully" do
          described_class.new.invoke(:modify, arguments, options)

          role = user.reload.role

          expect(role.name).to be_empty
        end
      end

      context 'with --email option' do
        let(:user) { Fabricate(:user, email: 'old_email@email.com') }
        let(:options) { { email: 'new_email@email.com' } }

        it "sets 'unconfirmed_email' with given email adress" do
          described_class.new.invoke(:modify, arguments, options)

          expect(user.reload.unconfirmed_email).to eq(options[:email])
        end

        it 'does not update original email address' do
          described_class.new.invoke(:modify, arguments, options)

          expect(user.reload.email).to eq('old_email@email.com')
        end

        context 'with --confirm option' do
          let(:user) { Fabricate(:user, email: 'old_email@email.com', confirmed_at: nil) }
          let(:options) { { email: 'new_email@email.com', confirm: true } }

          it "updates the user's email address" do
            described_class.new.invoke(:modify, arguments, options)

            expect(user.reload.email).to eq(options[:email])
          end

          it "set user's email address as confirmed" do
            described_class.new.invoke(:modify, arguments, options)

            expect(user.reload.confirmed?).to be(true)
          end
        end
      end

      context 'with --confirm option' do
        let(:user) { Fabricate(:user, confirmed_at: nil) }
        let(:options) { { confirm: true } }

        it "confirms user's email address" do
          described_class.new.invoke(:modify, arguments, options)

          expect(user.reload.confirmed?).to be(true)
        end
      end

      context 'with --approve option' do
        let(:user) { Fabricate(:user, approved: false) }
        let(:options) { { approve: true } }

        it 'approves user' do
          described_class.new.invoke(:modify, arguments, options)

          expect(user.reload.approved?).to be(true)
        end
      end

      context 'with --disable option' do
        let(:user) { Fabricate(:user, disabled: false) }
        let(:options) { { disable: true } }

        it 'disables the user' do
          described_class.new.invoke(:modify, arguments, options)

          expect(user.reload.disabled).to be(true)
        end
      end

      context 'with --enable option' do
        let(:user) { Fabricate(:user, disabled: true) }
        let(:options) { { enable: true } }

        it 'enables the user' do
          described_class.new.invoke(:modify, arguments, options)

          expect(user.reload.disabled).to be(false)
        end
      end

      context 'with --reset-password option' do
        let(:options) { { reset_password: true } }

        it "outputs new user's password" do
          allow(SecureRandom).to receive(:hex).and_return('new_password')

          expect { described_class.new.invoke(:modify, arguments, options) }
            .to output(
              a_string_including('new_password')
            ).to_stdout
        end
      end

      context 'with --disable-2fa option' do
        let(:user) { Fabricate(:user, otp_required_for_login: true) }
        let(:options) { { disable_2fa: true } }

        it "sets 'otp_required_for_login' to false" do
          described_class.new.invoke(:modify, arguments, options)

          expect(user.reload.otp_required_for_login).to be(false)
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
        expect { described_class.new.invoke(:delete, arguments, options) }
          .to output(
            a_string_including('Use username or --email, not both')
          ).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'when neither USERNAME nor --email are provided' do
      it 'returns an error message' do
        expect { described_class.new.invoke(:delete) }
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
        described_class.new.invoke(:delete, arguments)

        deleleted_user = Account.find_local(user.account.username)&.user

        expect(deleleted_user).to be_nil
      end

      context 'with --dry-run option' do
        let(:options) { { dry_run: true } }

        it 'does not delete the user' do
          described_class.new.invoke(:delete, arguments, options)

          expect(user.reload).to be_present
        end

        it 'outputs (DRY RUN) message' do
          expect { described_class.new.invoke(:delete, arguments, options) }
            .to output(
              a_string_including('OK (DRY RUN)')
            ).to_stdout
        end
      end

      context 'when given USERNAME is not found' do
        let(:arguments) { ['non_exitent_username'] }

        it 'returns an error message' do
          expect { described_class.new.invoke(:delete, arguments) }
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
        described_class.new.invoke(:delete, nil, options)

        deleleted_user = Account.find_local(user.account.username)&.user

        expect(deleleted_user).to be_nil
      end

      context 'with --dry-run option' do
        let(:options) { { email: user.email, dry_run: true } }

        it 'does not delete the user' do
          described_class.new.invoke(:delete, nil, options)

          expect(user.reload).to be_present
        end

        it 'outputs (DRY RUN) message' do
          expect { described_class.new.invoke(:delete, nil, options) }
            .to output(
              a_string_including('OK (DRY RUN)')
            ).to_stdout
        end
      end

      context 'when given email address is not found' do
        let(:options) { { email: '404@404.com' } }

        it 'returns an error message' do
          expect { described_class.new.invoke(:delete, nil, options) }
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
        described_class.new.invoke(:approve, nil, options)

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
          described_class.new.invoke(:approve, nil, options)

          n_earliest_pending_registrations = User.order(created_at: :asc).first(options[:number])

          expect(n_earliest_pending_registrations.all?(&:approved?)).to be(true)
        end

        it 'does not approve the remaining pending registrations' do
          described_class.new.invoke(:approve, nil, options)

          pending_registrations = User.order(created_at: :asc).last(total_users - options[:number])

          expect(pending_registrations.all?(&:approved?)).to be(false)
        end
      end

      context 'when the number is negative' do
        let(:options) { { number: -1 } }

        it 'returns an error message' do
          expect { described_class.new.invoke(:approve, nil, options) }
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
          described_class.new.invoke(:approve, nil, options)

          expect(User.pluck(:approved).all?(true)).to be(true)
        end

        it 'does not raise any error' do
          expect { described_class.new.invoke(:approve, nil, options) }
            .to_not raise_error(SystemExit)
        end
      end
    end

    context 'with USERNAME' do
      context 'when given USERNAME is found' do
        let(:user) { Fabricate(:user) }
        let(:arguments) { [user.account.username] }

        before { user.update(approved: false) }

        it 'approves user successfully' do
          described_class.new.invoke(:approve, arguments)

          expect(user.reload.approved?).to be(true)
        end
      end

      context 'when given USERNAME is not found' do
        let(:arguments) { ['non_existent_username'] }

        it 'returns an error message' do
          expect { described_class.new.invoke(:approve, arguments) }
            .to output(
              a_string_including('No such accoun')
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
        expect { described_class.new.invoke(:backup, arguments) }
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

        described_class.new.invoke(:backup, arguments)

        expect(BackupWorker).to have_received(:perform_async).once
      end

      it 'outputs a success message' do
        expect { described_class.new.invoke(:backup, arguments) }
          .to output(
            a_string_including('OK')
          ).to_stdout
      end
    end
  end
end
