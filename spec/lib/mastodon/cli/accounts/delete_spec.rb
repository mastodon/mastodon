# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts, '#delete' do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

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
end
