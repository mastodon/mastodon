# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts, '#create' do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

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
end
