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
end
