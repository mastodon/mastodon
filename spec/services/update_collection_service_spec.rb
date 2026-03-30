# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateCollectionService do
  subject { described_class.new }

  let(:collection) { Fabricate(:collection) }

  describe '#call' do
    context 'when given valid parameters' do
      it 'updates the collection' do
        subject.call(collection, { name: 'Newly updated name' })

        expect(collection.name).to eq 'Newly updated name'
      end

      context 'when something actually changed' do
        it 'federates an `Update` activity', feature: :collections_federation do
          subject.call(collection, { name: 'updated' })

          expect(ActivityPub::AccountRawDistributionWorker).to have_enqueued_sidekiq_job
        end
      end

      context 'when nothing changed' do
        it 'does not federate an activity', feature: :collections_federation do
          subject.call(collection, { name: collection.name })

          expect(ActivityPub::AccountRawDistributionWorker).to_not have_enqueued_sidekiq_job
        end
      end
    end

    context 'when given invalid parameters' do
      it 'raises an exception' do
        expect do
          subject.call(collection, { name: '' })
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
