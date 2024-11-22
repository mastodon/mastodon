# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PollVote do
  describe '#object_type' do
    let(:poll_vote) { Fabricate.build(:poll_vote) }

    it 'returns :vote' do
      expect(poll_vote.object_type).to eq :vote
    end
  end

  describe 'validations' do
    context 'with a vote on an expired poll' do
      it 'marks the vote invalid' do
        poll = Fabricate.build(:poll, expires_at: 30.days.ago)

        vote = Fabricate.build(:poll_vote, poll: poll)
        expect(vote).to_not be_valid
      end
    end

    context 'with invalid choices' do
      it 'marks vote invalid with negative choice' do
        poll = Fabricate.build(:poll)

        vote = Fabricate.build(:poll_vote, poll: poll, choice: -100)
        expect(vote).to_not be_valid
      end

      it 'marks vote invalid with choice in excess of options' do
        poll = Fabricate.build(:poll, options: %w(a b c))

        vote = Fabricate.build(:poll_vote, poll: poll, choice: 10)
        expect(vote).to_not be_valid
      end
    end

    context 'with a poll where multiple is true' do
      it 'does not allow a second vote on same choice from same account' do
        poll = Fabricate(:poll, multiple: true, options: %w(a b c))
        first_vote = Fabricate(:poll_vote, poll: poll, choice: 1)
        expect(first_vote).to be_valid

        second_vote = Fabricate.build(:poll_vote, account: first_vote.account, poll: poll, choice: 1)
        expect(second_vote).to_not be_valid
      end
    end

    context 'with a poll where multiple is false' do
      it 'does not allow a second vote from same account' do
        poll = Fabricate(:poll, multiple: false, options: %w(a b c))
        first_vote = Fabricate(:poll_vote, poll: poll)
        expect(first_vote).to be_valid

        second_vote = Fabricate.build(:poll_vote, account: first_vote.account, poll: poll)
        expect(second_vote).to_not be_valid
      end
    end
  end
end
