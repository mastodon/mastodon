# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::StatusEditSerializer do
  subject do
    serialized_record_json(
      status_edit,
      described_class
    )
  end

  let(:status_edit) { Fabricate(:status_edit) }

  context 'when created_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect { DateTime.rfc3339(subject['created_at']) }.to_not raise_error
    end
  end
end
