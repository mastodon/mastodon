# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fasp::BackfillRequest do
  describe '#next_objects' do
    let(:account) { Fabricate(:account) }
    let!(:statuses) { Fabricate.times(3, :status, account:).sort_by(&:id) }

    context 'with a new backfill request' do
      subject { Fabricate(:fasp_backfill_request, max_count: 2) }

      it 'returns the newest two statuses' do
        expect(subject.next_objects).to eq [statuses[2], statuses[1]]
      end
    end

    context 'with cursor set to second newest status' do
      subject do
        Fabricate(:fasp_backfill_request, max_count: 2, cursor: statuses[1].id)
      end

      it 'returns the oldest status' do
        expect(subject.next_objects).to eq [statuses[0]]
      end
    end

    context 'when all statuses are not `indexable`' do
      subject { Fabricate(:fasp_backfill_request) }

      let(:account) { Fabricate(:account, indexable: false) }

      it 'returns no statuses' do
        expect(subject.next_objects).to be_empty
      end
    end
  end

  describe '#next_uris' do
    subject { Fabricate(:fasp_backfill_request) }

    let(:statuses) { Fabricate.times(2, :status) }

    it 'returns uris of the next objects' do
      uris = statuses.map(&:uri)

      expect(subject.next_uris).to match_array(uris)
    end
  end

  describe '#more_objects_available?' do
    subject { Fabricate(:fasp_backfill_request, max_count: 2) }

    context 'when more objects are available' do
      before { Fabricate.times(3, :status) }

      it 'returns `true`' do
        expect(subject.more_objects_available?).to be true
      end
    end

    context 'when no more objects are available' do
      before { Fabricate.times(2, :status) }

      it 'returns `false`' do
        expect(subject.more_objects_available?).to be false
      end
    end
  end

  describe '#advance!' do
    subject { Fabricate(:fasp_backfill_request, max_count: 2) }

    context 'when more objects are available' do
      before { Fabricate.times(3, :status) }

      it 'updates `cursor`' do
        expect { subject.advance! }.to change(subject, :cursor)
        expect(subject).to be_persisted
      end
    end

    context 'when no more objects are available' do
      before { Fabricate.times(2, :status) }

      it 'sets `fulfilled` to `true`' do
        expect { subject.advance! }.to change(subject, :fulfilled)
          .from(false).to(true)
        expect(subject).to be_persisted
      end
    end
  end
end
