# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Admin::CohortSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Admin::Metrics::Retention.new('2024-01-01', '2024-01-02', 'day').cohorts.first }

  describe 'serialization' do
    it 'returns expected values' do
      expect(subject)
        .to include(
          'data' => be_a(Array),
          'period' => /2024-01-01/
        )
      expect { DateTime.rfc3339(subject['period']) }.to_not raise_error
      subject['data'].each { |datum| expect { DateTime.rfc3339(datum['date']) }.to_not raise_error }
    end
  end
end
