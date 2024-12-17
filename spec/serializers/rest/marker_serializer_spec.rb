# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::MarkerSerializer do
  subject do
    serialized_record_json(
      marker,
      described_class
    )
  end

  let(:marker) { Fabricate :marker }

  context 'when updated_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'updated_at' => match_api_datetime_format
        )
    end
  end
end
