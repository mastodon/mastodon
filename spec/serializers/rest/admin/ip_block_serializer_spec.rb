# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Admin::IpBlockSerializer do
  subject { serialized_record_json(record, described_class) }

  context 'when timestamps are populated' do
    let(:record) { Fabricate(:ip_block, expires_at: DateTime.new(2024, 11, 28, 16, 20, 0)) }

    it 'parses as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'created_at' => match_api_datetime_format,
          'expires_at' => match_api_datetime_format
        )
    end
  end
end
