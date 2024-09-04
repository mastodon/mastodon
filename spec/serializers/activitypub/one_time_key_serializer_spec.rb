# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::OneTimeKeySerializer do
  let(:serialization) { serialized_record_json(record, described_class) }
  let(:record) { Fabricate(:one_time_key) }

  describe 'type' do
    it 'returns correct serialized type' do
      expect(serialization['type']).to eq('Curve25519Key')
    end
  end
end
