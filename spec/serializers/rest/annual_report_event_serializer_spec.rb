# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::AnnualReportEventSerializer do
  subject { serialized_record_json(record, described_class) }

  describe 'serializing an object' do
    let(:record) { Fabricate.build :generated_annual_report, year: 2024 }

    it 'returns expected attributes' do
      expect(subject.deep_symbolize_keys)
        .to include(
          year: '2024'
        )
    end
  end
end
