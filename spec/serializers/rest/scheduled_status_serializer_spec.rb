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
  let(:scheduled_status) { Fabricate.build(:scheduled_status, scheduled_at: 4.minutes.from_now, account: account) }

  context 'with scheduled_at' do
    it 'is serialized as RFC 3339 datetime' do
      expect { DateTime.rfc3339(subject['scheduled_at']) }.to_not raise_error
    end
  end
end
