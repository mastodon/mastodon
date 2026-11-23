# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SEO::SocialMediaPostingSerializer do
  include RoutingHelper

  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate :status, text: 'Hello world' }

  describe 'Serialization' do
    it 'serializes expected values' do
      expect(subject)
        .to include(
          'context' => 'https://schema.org',
          'type' => 'SocialMediaPosting',
          'url' => ActivityPub::TagManager.instance.url_for(record),
          'date_published' => record.created_at.iso8601,
          'date_modified' => nil,
          'text' => '<p>Hello world</p>',
          'author' => include(
            'type' => 'Person',
            'name' => record.account.username
          )
        )
    end

    context 'when the status has been edited' do
      before { record.update! edited_at: 1.hour.ago }

      it 'includes the edit timestamp' do
        expect(subject['date_modified'])
          .to eq(record.edited_at.iso8601)
      end
    end

    context 'with an audio attachment' do
      let(:media) { Fabricate :media_attachment, type: :audio, description: 'An audio recording' }

      before { record.media_attachments << media }

      it 'serializes the audio attributes' do
        expect(subject['audio'])
          .to contain_exactly(
            'type' => 'AudioObject',
            'upload_date' => media.created_at.iso8601,
            'content_url' => full_asset_url(media.file.url(:original, false)),
            'thumbnail_url' => full_asset_url(media.file.url(:small)),
            'embed_url' => player_medium_url(media),
            'name' => 'An audio recording'
          )
      end
    end

    context 'with an image attachment' do
      let(:media) do
        Fabricate :media_attachment, type: :image, description: 'An image description', file_meta: { original: { width: 640, height: 480 } }
      end

      before { record.media_attachments << media }

      it 'serializes the image attributes' do
        expect(subject['image'])
          .to contain_exactly(
            'type' => 'ImageObject',
            'content_url' => full_asset_url(media.file.url(:original, false)),
            'thumbnail_url' => full_asset_url(media.file.url(:small)),
            'description' => 'An image description',
            'width' => 640,
            'height' => 480
          )
      end
    end

    context 'with a video attachment' do
      let(:media) { Fabricate :media_attachment, type: :video, description: 'A video recording' }

      before { record.media_attachments << media }

      it 'serializes the video attributes' do
        expect(subject['video'])
          .to contain_exactly(
            'type' => 'VideoObject',
            'upload_date' => media.created_at.iso8601,
            'content_url' => full_asset_url(media.file.url(:original, false)),
            'thumbnail_url' => full_asset_url(media.file.url(:small)),
            'embed_url' => player_medium_url(media),
            'name' => 'A video recording'
          )
      end
    end
  end
end
