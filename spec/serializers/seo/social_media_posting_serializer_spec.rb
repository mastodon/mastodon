# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SEO::SocialMediaPostingSerializer do
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
  end
end
