# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PollVote, type: :model do
  describe '#object_type' do
    let(:poll_vote) { Fabricate.build(:poll_vote) }

    it 'returns :vote' do
      expect(poll_vote.object_type).to eq :vote
    end
  end
end
