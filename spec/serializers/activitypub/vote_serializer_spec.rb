# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::VoteSerializer do
  let(:serialization) { serialized_record_json(record, described_class) }
  let(:record) { Fabricate(:poll_vote) }

  describe 'type' do
    it 'returns correct serialized type' do
      expect(serialization['type']).to eq('Create')
    end
  end
end
