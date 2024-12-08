# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Admin::IpBlockSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate(:ip_block) }

  context 'when created_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect { DateTime.rfc3339(subject['created_at']) }.to_not raise_error
    end
  end

  context 'when expires_at is populated' do
    let(:record) { Fabricate(:ip_block, expires_at: DateTime.new(2024, 11, 28, 16, 20, 0)) }

    it 'parses as RFC 3339 datetime' do
      expect { DateTime.rfc3339(subject['expires_at']) }.to_not raise_error
    end
  end
end
