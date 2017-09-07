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

  describe 'validatiions' do
    it 'has a valid fabricator' do
      report = Fabricate(:report)
      report.valid?
      expect(report).to be_valid
    end

    it 'is invalid if comment is longer than 1000 characters' do
      report = Fabricate.build(:report, comment: Faker::Lorem.characters(1001))
      report.valid?
      expect(report).to model_have_error_on_field(:comment)
    end
  end
end
