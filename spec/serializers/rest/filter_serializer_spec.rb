# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::FilterSerializer do
  subject do
    serialized_record_json(
      filter,
      described_class
    )
  end

  let(:filter) { Fabricate :custom_filter, expires_at: DateTime.new(2024, 11, 28, 16, 20, 0) }

  context 'when expires_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect { DateTime.rfc3339(subject['expires_at']) }.to_not raise_error
    end
  end
end
