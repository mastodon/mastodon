# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Keys::QueryResultSerializer do
  let(:serialization) { serialized_record_json(record, described_class) }
  let(:record) { Keys::QueryService::Result.new(Account.new(id: 123), []) }

  describe 'account' do
    it 'returns the associated account id' do
      expect(serialization['account_id']).to eq('123')
    end
  end
end
