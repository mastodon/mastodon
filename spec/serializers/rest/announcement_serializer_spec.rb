# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::AnnouncementSerializer do
  subject do
    serialized_record_json(
      announcement,
      described_class,
      options: {
        scope: current_user,
        scope_name: :current_user,
      }
    )
  end

  let(:current_user) { Fabricate(:user) }
  let(:announcement) { Fabricate(:announcement, starts_at: 10.days.ago, published_at: 10.days.ago, ends_at: 5.days.from_now) }

  context 'when date fields are populated' do
    it 'parses as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'starts_at' => match_api_datetime_format,
          'ends_at' => match_api_datetime_format,
          'published_at' => match_api_datetime_format,
          'updated_at' => match_api_datetime_format
        )
    end
  end
end
