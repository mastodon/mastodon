# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Admin::IpSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { UserIp.new(used_at: 3.days.ago) }

  context 'when used_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'used_at' => match_api_datetime_format
        )
    end
  end
end
