# frozen_string_literal: true

require 'rails_helper'
require 'mastodon/cli/accounts'

RSpec.describe Mastodon::CLI::Accounts, '#backup' do
  subject { cli.invoke(action, arguments, options) }

  let(:cli) { described_class.new }
  let(:arguments) { [] }
  let(:options) { {} }

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
end
