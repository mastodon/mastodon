# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::AccountWarningSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate :account_warning, id: 123, status_ids: [456, 789] }

  describe 'serialization' do
    it 'returns expected values' do
      expect(subject)
        .to include(
          'id' => be_a(String).and(eq('123')),
          'status_ids' => be_a(Array).and(eq(['456', '789']))
        )
    end
  end
end
