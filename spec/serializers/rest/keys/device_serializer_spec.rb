# frozen_string_literal: true

require 'rails_helper'

describe REST::Keys::DeviceSerializer do
  let(:serialization) do
    JSON.parse(
      ActiveModelSerializers::SerializableResource.new(
        record, serializer: described_class
      ).to_json
    )
  end
  let(:record) { Device.new(name: 'Device name') }

  describe 'name' do
    it 'returns the name' do
      expect(serialization['name']).to eq('Device name')
    end
  end
end
