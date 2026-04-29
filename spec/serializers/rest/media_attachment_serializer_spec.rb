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
    let(:expected_meta_keys) { %w[focus colors original small] }

    it 'returns filtered file meta with only allowed keys' do
      meta = subject['meta']

      expect(meta).to be_present
      expect(meta.keys).to all(satisfy { |key| expected_meta_keys.include?(key) })
    end

    context 'when file.meta is nil' do
      before do
        allow(media_attachment.file).to receive(:meta).and_return(nil)
      end

      it 'returns nil' do
        expect(subject['meta']).to be_nil
      end
    end

    context 'when file.meta is blank' do
      before do
        allow(media_attachment.file).to receive(:meta).and_return('')
      end

      it 'returns nil' do
        expect(subject['meta']).to be_nil
      end
    end

    context 'when file.meta is not a Hash' do
      before do
        allow(media_attachment.file).to receive(:meta).and_return('invalid meta string')
      end

      it 'returns nil instead of raising error' do
        expect(subject['meta']).to be_nil
      end
    end

    context 'when file.meta is an empty Hash' do
      before do
        allow(media_attachment.file).to receive(:meta).and_return({})
      end

      it 'returns nil' do
        expect(subject['meta']).to be_nil
      end
    end

    context 'when file.meta has extra keys not in META_KEYS' do
      let(:meta_with_extra) do
        {
          'original' => { 'width' => 600, 'height' => 400 },
          'small' => { 'width' => 588, 'height' => 392 },
          'extra_key' => 'should be filtered out',
          'sensitive_path' => '/Users/secret/file.txt',
        }
      end

      before do
        allow(media_attachment.file).to receive(:meta).and_return(meta_with_extra)
      end

      it 'filters out extra keys not in META_KEYS' do
        meta = subject['meta']

        expect(meta.keys).to match_array(%w[original small])
        expect(meta).not_to include('extra_key')
        expect(meta).not_to include('sensitive_path')
      end

      it 'preserves allowed keys with their values' do
        expect(subject['meta']['original']).to eq({ 'width' => 600, 'height' => 400 })
        expect(subject['meta']['small']).to eq({ 'width' => 588, 'height' => 392 })
      end
    end

    context 'when file.meta contains sensitive paths in values' do
      let(:meta_with_sensitive_values) do
        {
          'original' => { 'width' => 600, 'path' => '/Users/secret/file.txt' },
          'focus' => { 'x' => 0.5, 'y' => 0.5 },
        }
      end

      before do
        allow(media_attachment.file).to receive(:meta).and_return(meta_with_sensitive_values)
      end

      it 'returns the meta as-is (values are not filtered)' do
        expect(subject['meta']).to include('original' => include('path' => '/Users/secret/file.txt'))
      end
    end

    context 'when file.meta raises an exception' do
      before do
        allow(media_attachment.file).to receive(:meta).and_raise(StandardError, 'Error accessing meta at /Users/test/path')
      end

      it 'returns nil instead of raising error' do
        expect { subject }.not_to raise_error
        expect(subject['meta']).to be_nil
      end
    end

    context 'when file.meta raises a NoMethodError' do
      before do
        allow(media_attachment.file).to receive(:meta).and_raise(NoMethodError, 'undefined method for nil:NilClass')
      end

      it 'returns nil instead of raising error' do
        expect { subject }.not_to raise_error
        expect(subject['meta']).to be_nil
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
