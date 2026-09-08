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
    it { is_expected.to_not allow_value([]).for(:options) }
  end

  describe 'Callbacks' do
    describe 'Normalizing options' do
      context 'when values are missing and padded' do
        let(:poll) { Fabricate.build :poll }

        before { poll.options = ['One', '', '  Three  '] }

        it 'strips and compacts the array' do
          expect { poll.valid? }
            .to change(poll, :options).to(%w(One Three))
        end
      end
    end
  end

  describe '#loaded_options' do
    before { poll.options = %w(One Two) }

    context 'with a poll hiding totals' do
      let(:poll) { Fabricate.build :poll, hide_totals: true }

      it 'returns serialized option values' do
        expect(poll.loaded_options)
          .to be_an(Array)
          .and contain_exactly(
            be_a(Poll::Option).and(have_attributes(poll:, id: '0', votes_count: nil, title: /One/)),
            be_a(Poll::Option).and(have_attributes(poll:, id: '1', votes_count: nil, title: /Two/))
          )
      end
    end

    context 'with an expired poll' do
      let(:poll) { Fabricate.build :poll, expires_at: 5.days.ago }

      it 'returns serialized option values' do
        expect(poll.loaded_options)
          .to be_an(Array)
          .and contain_exactly(
            be_a(Poll::Option).and(have_attributes(poll:, id: '0', votes_count: 0, title: /One/)),
            be_a(Poll::Option).and(have_attributes(poll:, id: '1', votes_count: 0, title: /Two/))
          )
      end
    end
  end
end
