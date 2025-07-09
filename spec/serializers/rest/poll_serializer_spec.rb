# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::PollSerializer do
  subject do
    serialized_record_json(
      poll,
      described_class,
      options: {
        scope: current_user,
        scope_name: :current_user,
      }
    )
  end

  let(:current_user) { Fabricate(:user) }
  let(:poll) { Fabricate.build :poll, expires_at: 5.days.from_now }

  context 'when expires_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'expires_at' => match_api_datetime_format
        )
    end
  end
end
