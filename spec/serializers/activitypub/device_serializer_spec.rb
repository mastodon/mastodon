# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::DeviceSerializer do
  let(:serialization) do
    JSON.parse(
      ActiveModelSerializers::SerializableResource.new(
        record, serializer: described_class
      ).to_json
    )
  end
  let(:record) { Fabricate(:device) }

  describe 'type' do
    it 'returns correct serialized type' do
      expect(serialization['type']).to eq('Device')
    end
  end
end
