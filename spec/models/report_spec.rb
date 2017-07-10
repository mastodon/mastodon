require 'rails_helper'

describe Report do
  describe 'statuses' do
    it 'returns the statuses for the report' do
      status = Fabricate(:status)
      _other = Fabricate(:status)
      report = Fabricate(:report, status_ids: [status.id])

      expect(report.statuses).to eq [status]
    end
  end

  describe 'media_attachments' do
    it 'returns media attachments from statuses' do
      status = Fabricate(:status)
      media_attachment = Fabricate(:media_attachment, status: status)
      _other_media_attachment = Fabricate(:media_attachment)
      report = Fabricate(:report, status_ids: [status.id])

      expect(report.media_attachments).to eq [media_attachment]
    end
  end
end
