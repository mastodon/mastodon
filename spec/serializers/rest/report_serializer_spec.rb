# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::ReportSerializer do
  subject do
    serialized_record_json(
      report,
      described_class
    )
  end

  let(:status) { Fabricate(:status) }
  let(:report) { Fabricate(:report, status_ids: [status.id]) }

  context 'with created_at' do
    it 'is serialized as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'created_at' => match_api_datetime_format
        )
    end
  end

  context 'with action_taken_at' do
    let(:acting_account) { Fabricate(:account) }

    before do
      report.resolve!(acting_account)
    end

    it 'is serialized as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'action_taken_at' => match_api_datetime_format
        )
    end
  end
end
