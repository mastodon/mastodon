# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts, '#modify' do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

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
end
