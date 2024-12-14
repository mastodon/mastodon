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

  context 'when created_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect { DateTime.rfc3339(subject['created_at']) }.to_not raise_error
    end
  end

  context 'when updated_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect { DateTime.rfc3339(subject['updated_at']) }.to_not raise_error
    end
  end
end
