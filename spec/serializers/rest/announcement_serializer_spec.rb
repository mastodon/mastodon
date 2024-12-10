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
      expect { DateTime.rfc3339(subject['starts_at']) }.to_not raise_error
      expect { DateTime.rfc3339(subject['ends_at']) }.to_not raise_error
      expect { DateTime.rfc3339(subject['published_at']) }.to_not raise_error
      expect { DateTime.rfc3339(subject['updated_at']) }.to_not raise_error
    end
  end
end
