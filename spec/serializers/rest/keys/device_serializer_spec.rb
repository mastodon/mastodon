# frozen_string_literal: true

require 'rails_helper'

RSpec.describe REST::Keys::DeviceSerializer do
  let(:serialization) { serialized_record_json(record, described_class) }
  let(:record) { Device.new(name: 'Device name') }

  describe 'name' do
    it 'returns the name' do
      expect(serialization['name']).to eq('Device name')
    end
  end
end
