# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateCollectionService do
  subject { described_class.new }

  let(:collection) { Fabricate(:collection) }
  let!(:collection_item) { Fabricate(:collection_item, collection:) }

  describe '#call' do
    context 'when given valid parameters' do
      it 'updates the collection, sends a notification and federates an `Update` activity' do
        expect { subject.call(collection, { name: 'Newly updated name' }) }
          .to change(collection, :name).to('Newly updated name')
          .and enqueue_sidekiq_job(LocalNotificationWorker).with(collection_item.account_id, collection.id, collection.class.name, 'collection_update')
          .and enqueue_sidekiq_job(ActivityPub::AccountRawDistributionWorker)
      end

      context 'when nothing changed' do
        it 'does not federate an activity' do
          subject.call(collection, { name: collection.name })

          expect(ActivityPub::AccountRawDistributionWorker).to_not have_enqueued_sidekiq_job
          expect(LocalNotificationWorker).to_not have_enqueued_sidekiq_job
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
