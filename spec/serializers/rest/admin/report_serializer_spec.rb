# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Admin::ReportSerializer do
  subject { serialized_record_json(report, described_class) }

  context 'with timestamps' do
    let(:report) { Fabricate(:report, action_taken_at: 3.days.ago) }

    it 'is serialized as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'action_taken_at' => match_api_datetime_format,
          'created_at' => match_api_datetime_format
        )
    end
  end
end
