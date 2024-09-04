# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Keys::ClaimResultSerializer do
  let(:serialization) { serialized_record_json(record, described_class) }
  let(:record) { Keys::ClaimService::Result.new(Account.new(id: 123), 456) }

  describe 'account' do
    it 'returns the associated account' do
      expect(serialization['account_id']).to eq('123')
    end
  end
end
