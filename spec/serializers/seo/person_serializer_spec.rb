# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SEO::PersonSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate :account, display_name: display_name, note: 'A short biography' }
  let(:display_name) { 'Alice' }

  describe 'Serialization' do
    it 'serializes expected values' do
      expect(subject)
        .to include(
          'type' => 'Person',
          'name' => 'Alice',
          'alternate_name' => "#{record.username}@#{Rails.configuration.x.local_domain}",
          'identifier' => "#{record.username}@#{Rails.configuration.x.local_domain}",
          'description' => 'A short biography',
          'url' => ActivityPub::TagManager.instance.url_for(record)
        )
    end

    context 'when the display name is blank' do
      let(:display_name) { '' }

      it 'uses the username as the name' do
        expect(subject['name'])
          .to eq(record.username)
      end
    end
  end
end
