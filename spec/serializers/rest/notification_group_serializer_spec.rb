# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::NotificationGroupSerializer do
  subject do
    serialized_record_json(
      notification_group,
      described_class
    )
  end

  let(:notification_group) { NotificationGroup.new pagination_data: { latest_notification_at: 3.days.ago }, notification: Fabricate(:notification), sample_accounts: [] }

  context 'when latest_page_notification_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect { DateTime.rfc3339(subject['latest_page_notification_at']) }.to_not raise_error
    end
  end
end
