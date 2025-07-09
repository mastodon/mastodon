# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Poll do
  it_behaves_like 'Expireable'

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
