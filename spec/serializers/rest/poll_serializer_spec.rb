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
  let(:poll) { Fabricate :poll }

  context 'when expires_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect { DateTime.rfc3339(subject['expires_at']) }.to_not raise_error
    end
  end
end
