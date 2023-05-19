# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::UndoLikeSerializer do
  let(:serialization) do
    JSON.parse(
      ActiveModelSerializers::SerializableResource.new(
        record, serializer: described_class
      ).to_json
    )
  end
  let(:record) { Fabricate(:favourite) }

  describe 'type' do
    it 'returns correct serialized type' do
      expect(serialization['type']).to eq('Undo')
    end
  end
end
