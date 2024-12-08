# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Admin::EmailDomainBlockSerializer do
  subject { serialized_record_json(record, described_class) }

  let(:record) { Fabricate(:email_domain_block) }

  context 'when created_at is populated' do
    it 'parses as RFC 3339 datetime' do
      expect { DateTime.rfc3339(subject['created_at']) }.to_not raise_error
    end
  end
end
