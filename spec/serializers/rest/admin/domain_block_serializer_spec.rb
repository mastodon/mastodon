# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Admin::DomainBlockSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate(:domain_block) }

  context 'when created_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect(subject)
        .to include(
          'created_at' => match_api_datetime_format
        )
    end
  end
end
