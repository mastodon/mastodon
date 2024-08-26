# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::DeviceSerializer do
  let(:serialization) { serialized_record_json(record, described_class) }
  let(:record) { Fabricate(:device) }

  describe 'type' do
    it 'returns correct serialized type' do
      expect(serialization['type']).to eq('Device')
    end
  end
end
