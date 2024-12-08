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
      expect { DateTime.rfc3339(subject['updated_at']) }.to_not raise_error
    end
  end
end
