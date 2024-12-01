# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Admin::IpSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate(:ip) }

  context 'when used_at is populated', pending: 'No class found for ip' do
    it 'parses as RFC 3339 datetime' do
      expect { DateTime.rfc3339(subject['used_at']) }.to_not raise_error
    end
  end
end
