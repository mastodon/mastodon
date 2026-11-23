# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SEO::ProfilePageSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate :account }

  describe 'Serialization' do
    it 'serializes expected values' do
      expect(subject)
        .to include(
          'context' => 'https://schema.org',
          'type' => 'ProfilePage',
          'date_published' => record.created_at.iso8601,
          'date_modified' => record.updated_at.iso8601,
          'main_entity' => include(
            'type' => 'Person',
            'name' => record.username
          )
        )
    end
  end
end
