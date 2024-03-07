# frozen_string_literal: true

require 'rails_helper'

describe BackupWorker do
  let(:worker) { described_class.new }
  let(:service) { instance_double(BackupService, call: true) }

  describe '#perform' do
    before do
      allow(BackupService).to receive(:new).and_return(service)
    end

    let(:backup) { Fabricate(:backup) }
    let!(:other_backup) { Fabricate(:backup, user: backup.user) }

    it 'sends the backup to the service and removes other backups', :sidekiq_inline do
      emails = capture_emails { worker.perform(backup.id) }

      expect(service).to have_received(:call).with(backup)
      expect { other_backup.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(emails.size)
        .to eq(1)
      expect(emails.first)
        .to have_attributes(
          to: contain_exactly(backup.user.email),
          subject: I18n.t('user_mailer.backup_ready.subject')
        )
    end

    context 'when sidekiq retries are exhausted' do
      it 'destroys the backup' do
        described_class.within_sidekiq_retries_exhausted_block({ 'args' => [backup.id] }) do
          worker.perform(backup.id)
        end

        expect { backup.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
