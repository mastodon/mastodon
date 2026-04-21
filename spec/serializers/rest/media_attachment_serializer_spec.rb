# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::MediaAttachmentSerializer do
  let(:serializer) { described_class.new(media_attachment) }
  let(:media_attachment) { Fabricate(:media_attachment, account: account) }
  let(:account) { Fabricate(:account) }

  describe '#meta' do
    context 'when file.meta is a valid hash with allowed keys' do
      before do
        media_attachment.file.instance_write(:meta, {
          original: { width: 600, height: 400, aspect: 1.5 },
          small: { width: 300, height: 200, aspect: 1.5 },
          focus: { x: 0.5, y: 0.5 },
          colors: { primary: '#ffffff' }
        })
      end

      it 'returns only allowed keys' do
        expect(serializer.meta).to include(
          'original' => include('width' => 600, 'height' => 400),
          'small' => include('width' => 300, 'height' => 200),
          'focus' => include('x' => 0.5, 'y' => 0.5),
          'colors' => include('primary' => '#ffffff')
        )
      end

      it 'does not include extra keys' do
        media_attachment.file.instance_write(:meta, {
          original: { width: 600 },
          extra_key: 'should not be included'
        })
        expect(serializer.meta).not_to include('extra_key')
      end
    end

    context 'when file.meta is nil' do
      before do
        media_attachment.file.instance_write(:meta, nil)
      end

      it 'returns an empty hash' do
        expect(serializer.meta).to eq({})
      end
    end

    context 'when file.meta is not a hash' do
      it 'returns an empty hash for string' do
        media_attachment.file.instance_write(:meta, 'invalid string')
        expect(serializer.meta).to eq({})
      end

      it 'returns an empty hash for array' do
        media_attachment.file.instance_write(:meta, ['invalid', 'array'])
        expect(serializer.meta).to eq({})
      end

      it 'returns an empty hash for number' do
        media_attachment.file.instance_write(:meta, 123)
        expect(serializer.meta).to eq({})
      end

      it 'returns an empty hash for boolean' do
        media_attachment.file.instance_write(:meta, true)
        expect(serializer.meta).to eq({})
      end
    end

    context 'when file.meta is an empty hash' do
      before do
        media_attachment.file.instance_write(:meta, {})
      end

      it 'returns an empty hash' do
        expect(serializer.meta).to eq({})
      end
    end

    context 'when file.meta contains only non-allowed keys' do
      before do
        media_attachment.file.instance_write(:meta, {
          invalid_key1: 'value1',
          invalid_key2: 'value2'
        })
      end

      it 'returns an empty hash' do
        expect(serializer.meta).to eq({})
      end
    end

    context 'with symbolized keys' do
      before do
        media_attachment.file.instance_write(:meta, {
          original: { width: 600, height: 400 },
          focus: { x: 0.5, y: 0.5 }
        })
      end

      it 'accesses values correctly with indifferent access' do
        expect(serializer.meta['original']).to include('width' => 600, 'height' => 400)
        expect(serializer.meta['focus']).to include('x' => 0.5, 'y' => 0.5)
      end
    end

    context 'with string keys' do
      before do
        media_attachment.file.instance_write(:meta, {
          'original' => { 'width' => 600, 'height' => 400 },
          'focus' => { 'x' => 0.5, 'y' => 0.5 }
        })
      end

      it 'accesses values correctly' do
        expect(serializer.meta['original']).to include('width' => 600, 'height' => 400)
        expect(serializer.meta['focus']).to include('x' => 0.5, 'y' => 0.5)
      end
    end
  end

  describe 'full serialization' do
    before do
      media_attachment.file.instance_write(:meta, {
        original: { width: 600, height: 400, aspect: 1.5 },
        small: { width: 300, height: 200, aspect: 1.5 },
        focus: { x: 0.5, y: 0.5 }
      })
    end

    it 'serializes successfully without errors' do
      expect { serializer.as_json }.not_to raise_error
    end

    it 'includes meta in the serialized output' do
      json = serializer.as_json
      expect(json).to include(:meta)
      expect(json[:meta]).to include(
        'original' => include('width' => 600, 'height' => 400),
        'small' => include('width' => 300, 'height' => 200),
        'focus' => include('x' => 0.5, 'y' => 0.5)
      )
    end

    it 'converts to JSON string without errors' do
      json = serializer.as_json
      expect { json.to_json }.not_to raise_error
    end

    context 'with invalid metadata types' do
      before do
        media_attachment.file.instance_write(:meta, 'invalid string metadata')
      end

      it 'serializes successfully with empty meta' do
        json = serializer.as_json
        expect(json[:meta]).to eq({})
      end

      it 'does not raise errors during JSON serialization' do
        json = serializer.as_json
        expect { json.to_json }.not_to raise_error
      end
    end

    context 'with nil metadata' do
      before do
        media_attachment.file.instance_write(:meta, nil)
      end

      it 'serializes successfully with empty meta' do
        json = serializer.as_json
        expect(json[:meta]).to eq({})
      end
    end
  end
end
