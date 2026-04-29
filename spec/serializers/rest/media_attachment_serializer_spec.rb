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

  describe '#meta' do
    it 'returns file meta' do
      expect(subject['meta']).to be_present
    end

    context 'when file.meta raises an error' do
      before do
        allow(media_attachment.file).to receive(:meta).and_raise(StandardError, 'Error with /Users/test/path')
      end

      it 'raises an error that should be handled by the controller' do
        expect { subject }.to raise_error(StandardError)
      end
    end
  end

  describe '#url' do
    it 'returns the file URL' do
      expect(subject['url']).to be_present
    end

    context 'when media is not processed' do
      before do
        media_attachment.processing = :queued
      end

      it 'returns nil' do
        expect(subject['url']).to be_nil
      end
    end
  end

  describe 'serialization attributes' do
    it 'includes all required attributes' do
      expect(subject).to include(
        'id' => media_attachment.id.to_s,
        'type' => media_attachment.type,
        'url' => be_present,
        'preview_url' => be_present,
        'description' => media_attachment.description,
        'blurhash' => media_attachment.blurhash
      )
    end
  end
end
