# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::UndoLikeSerializer do
  let(:serialization) { serialized_record_json(record, described_class) }
  let(:record) { Fabricate(:favourite) }

  describe 'type' do
    it 'returns correct serialized type' do
      expect(serialization['type']).to eq('Undo')
    end
  end
end
