# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::AccountRelationshipSeveranceEventSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate.build :account_relationship_severance_event, id: 123, created_at: DateTime.new(2024, 11, 28, 16, 20, 0) }

  describe 'serialization' do
    it 'returns expected values' do
      expect(subject)
        .to include(
          'id' => be_a(String).and(eq('123')),
          'created_at' => match_api_datetime_format
        )
    end
  end
end
