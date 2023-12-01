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

    it 'sends the backup to the service and removes other backups' do
      expect do
        worker.perform(backup.id)
      end.to change(UserMailer.deliveries, :size).by(1)

      expect(service).to have_received(:call).with(backup)
      expect { other_backup.reload }.to raise_error(ActiveRecord::RecordNotFound)
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
