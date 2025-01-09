# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::NotificationRequestSerializer do
  subject do
    serialized_record_json(
      notification_request,
      described_class,
      options: {
        scope: current_user,
        scope_name: :current_user,
      }
    )
  end

  let(:current_user) { Fabricate(:user) }
  let(:notification_request) { Fabricate :notification_request }

  context 'when timestampts are populated' do
    it 'parses as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'created_at' => match_api_datetime_format,
          'updated_at' => match_api_datetime_format
        )
    end
  end
end
