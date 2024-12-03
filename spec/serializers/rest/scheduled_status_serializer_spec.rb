# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::ScheduledStatusSerializer do
  subject do
    serialized_record_json(
      scheduled_status,
      described_class
    )
  end

  let(:account) { Fabricate(:account) }
  let(:scheduled_status) { Fabricate.build(:scheduled_status, scheduled_at: 4.minutes.from_now, account: account, params: { application_id: 123 }) }

  describe 'serialization' do
    it 'is serialized as RFC 3339 datetime' do
      expect { DateTime.rfc3339(subject['scheduled_at']) }
        .to_not raise_error
    end

    it 'returns expected values and removes application_id from params' do
      expect(subject.deep_symbolize_keys)
        .to include(scheduled_at: be_a(String))
        .and include(params: not_include(:application_id))
    end
  end
end
