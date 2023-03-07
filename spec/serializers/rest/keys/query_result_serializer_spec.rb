# frozen_string_literal: true

require 'rails_helper'

describe REST::Keys::QueryResultSerializer do
  let(:serialization) do
    JSON.parse(
      ActiveModelSerializers::SerializableResource.new(
        record, serializer: described_class
      ).to_json
    )
  end
  let(:record) { Keys::QueryService::Result.new(Account.new(id: 123), []) }

  describe 'account' do
    it 'returns the associated account id' do
      expect(serialization['account_id']).to eq('123')
    end
  end
end
