# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Admin::MeasureSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:start_at) { 2.days.ago }
  let(:end_at) { Time.now.utc }
  let(:params) { ActionController::Parameters.new({ instance_accounts: [123] }) }
  let(:record) { Admin::Metrics::Measure::ActiveUsersMeasure.new(start_at, end_at, params) }

  context 'when start_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'data' => all(
            include('date' => match_api_datetime_format)
          )
        )
    end
  end
end
