# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Poll do
  describe 'Scopes' do
    let(:status) { Fabricate(:status) }
    let(:attached_poll) { Fabricate(:poll, status: status) }
    let(:not_attached_poll) do
      Fabricate(:poll).tap do |poll|
        poll.status = nil
        poll.save(validate: false)
      end
    end

    describe '.attached' do
      it 'finds the correct records' do
        results = described_class.attached

        expect(results).to eq([attached_poll])
      end
    end

    describe '.unattached' do
      it 'finds the correct records' do
        results = described_class.unattached

        expect(results).to eq([not_attached_poll])
      end
    end
  end

  describe '#reset_votes!' do
    let(:poll) { Fabricate :poll, cached_tallies: [2, 3], votes_count: 5, voters_count: 5 }
    let!(:vote) { Fabricate :poll_vote, poll: }

    it 'resets vote data and deletes votes' do
      expect { poll.reset_votes! }
        .to change(poll, :cached_tallies).to([0, 0])
        .and change(poll, :votes_count).to(0)
        .and(change(poll, :voters_count).to(0))
      expect { vote.reload }
        .to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'Validations' do
    subject { Fabricate.build(:poll) }

    it { is_expected.to validate_presence_of(:expires_at) }
  end
end
