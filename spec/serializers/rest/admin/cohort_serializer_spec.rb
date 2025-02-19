# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Admin::CohortSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Admin::Metrics::Retention.new('2024-01-01', '2024-01-02', 'day').cohorts.first }

  describe 'serialization' do
    it 'returns expected values' do
      expect(subject)
        .to include(
          'data' => be_a(Array).and(
            all(include('date' => match_api_datetime_format))
          ),
          'period' => match(/2024-01-01/).and(match_api_datetime_format)
        )
    end
  end
end
