# frozen_string_literal: true

require 'rails_helper'

describe REST::Keys::ClaimResultSerializer do
  let(:serialization) do
    JSON.parse(
      ActiveModelSerializers::SerializableResource.new(
        record, serializer: described_class
      ).to_json
    )
  end
  let(:record) { Keys::ClaimService::Result.new(Account.new(id: 123), 456) }

  describe 'account' do
    it 'returns the associated account' do
      expect(serialization['account_id']).to eq('123')
    end
  end
end
