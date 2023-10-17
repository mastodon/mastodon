# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::OneTimeKeySerializer do
  let(:serialization) do
    JSON.parse(
      ActiveModelSerializers::SerializableResource.new(
        record, serializer: described_class
      ).to_json
    )
  end
  let(:record) { Fabricate(:one_time_key) }

  describe 'type' do
    it 'returns correct serialized type' do
      expect(serialization['type']).to eq('Curve25519Key')
    end
  end
end
