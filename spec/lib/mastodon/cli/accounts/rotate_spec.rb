# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts, '#rotate' do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

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
end
