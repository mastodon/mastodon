# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::RuleSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate.build :rule, id: 123 }

  describe 'serialization' do
    it 'returns expected values' do
      expect(subject)
        .to include(
          'id' => be_a(String).and(eq('123')),
          'translations' => be_a(Hash)
        )
    end
  end
end
