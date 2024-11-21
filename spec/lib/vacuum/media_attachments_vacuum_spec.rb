# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Vacuum::MediaAttachmentsVacuum do
  subject { described_class.new(retention_period) }

  let(:retention_period) { 7.days }
  let(:remote_status) { Fabricate(:status, account: Fabricate(:account, domain: 'example.com')) }
  let(:local_status) { Fabricate(:status) }

  describe '#perform' do
    let!(:old_remote_media) { Fabricate(:media_attachment, remote_url: 'https://example.com/foo.png', status: remote_status, created_at: (retention_period + 1.day).ago, updated_at: (retention_period + 1.day).ago) }
    let!(:old_local_media) { Fabricate(:media_attachment, status: local_status, created_at: (retention_period + 1.day).ago, updated_at: (retention_period + 1.day).ago) }
    let!(:new_remote_media) { Fabricate(:media_attachment, remote_url: 'https://example.com/foo.png', status: remote_status) }
    let!(:new_local_media) { Fabricate(:media_attachment, status: local_status) }
    let!(:old_unattached_media) { Fabricate(:media_attachment, account_id: nil, created_at: 10.days.ago) }
    let!(:new_unattached_media) { Fabricate(:media_attachment, account_id: nil, created_at: 1.hour.ago) }

    it 'handles attachments based on metadata details' do
      subject.perform

      expect(old_remote_media.reload.file) # Remote and past retention period
        .to be_blank
      expect(old_local_media.reload.file) # Local and past retention
        .to_not be_blank
      expect(new_remote_media.reload.file) # Remote and within retention
        .to_not be_blank
      expect(new_local_media.reload.file) # Local and within retention
        .to_not be_blank
      expect { old_unattached_media.reload } # Unattached and past TTL
        .to raise_error(ActiveRecord::RecordNotFound)
      expect(new_unattached_media.reload) # Unattached and within TTL
        .to be_persisted
    end
  end
end
