require 'rails_helper'

RSpec.describe Vacuum::StatusesVacuum do
  subject { described_class.new(retention_period) }

  let(:retention_period) { 7.days }

  let(:remote_account) { Fabricate(:account, domain: 'example.com') }

  describe '#perform' do
    let!(:remote_status_old) { Fabricate(:status, account: remote_account, created_at: (retention_period + 2.days).ago) }
    let!(:remote_status_recent) { Fabricate(:status, account: remote_account, created_at: (retention_period - 2.days).ago) }
    let!(:local_status_old) { Fabricate(:status, created_at: (retention_period + 2.days).ago) }
    let!(:local_status_recent) { Fabricate(:status, created_at: (retention_period - 2.days).ago) }

    before do
      subject.perform
    end

    it 'deletes remote statuses past the retention period' do
      expect { remote_status_old.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'does not delete local statuses past the retention period' do
      expect { local_status_old.reload }.to_not raise_error
    end

    it 'does not delete remote statuses within the retention period' do
      expect { remote_status_recent.reload }.to_not raise_error
    end

    it 'does not delete local statuses within the retention period' do
      expect { local_status_recent.reload }.to_not raise_error
    end
  end
end
