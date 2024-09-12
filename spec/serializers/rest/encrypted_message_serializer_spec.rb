# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::EncryptedMessageSerializer do
  let(:serialization) { serialized_record_json(record, described_class) }
  let(:record) { Fabricate(:encrypted_message) }

  describe 'account' do
    it 'returns the associated account' do
      expect(serialization['account_id']).to eq(record.from_account.id.to_s)
    end
  end
end
