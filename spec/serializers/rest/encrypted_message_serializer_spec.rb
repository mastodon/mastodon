# frozen_string_literal: true

require 'rails_helper'

describe REST::EncryptedMessageSerializer do
  let(:serialization) do
    JSON.parse(
      ActiveModelSerializers::SerializableResource.new(
        record, serializer: described_class
      ).to_json
    )
  end
  let(:record) { Fabricate(:encrypted_message) }

  describe 'account' do
    it 'returns the associated account' do
      expect(serialization['account_id']).to eq(record.from_account.id.to_s)
    end
  end
end
