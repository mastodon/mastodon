# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::MediaAttachmentSerializer do
  subject do
    serialized_record_json(
      media_attachment,
      described_class
    )
  end

  let(:media_attachment) { Fabricate(:media_attachment) }

  context 'with a status' do
    let(:status) { Fabricate(:status) }
    let(:media_attachment) { Fabricate(:media_attachment, status: status) }

    it 'returns the status ID' do
      expect(subject['status_id']).to eq status.id.to_s
    end
  end

  context 'without a status' do
    it 'returns nil' do
      expect(subject['status_id']).to be_nil
    end
  end
end
