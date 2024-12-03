# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::ScheduledStatusSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate :scheduled_status, scheduled_at: 2.days.from_now, params: { application_id: 123 } }

  describe 'serialization' do
    it 'returns expected values and removes application id from params' do
      expect(subject.deep_symbolize_keys)
        .to include(scheduled_at: be_a(String))
        .and include(params: not_include(:application_id))
    end
  end
end
