# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteCollectionItemService do
  subject { described_class.new }

  let(:collection_item) { Fabricate(:collection_item) }
  let(:collection) { collection_item.collection }

  describe '#call' do
    it 'destroys the collection' do
      expect { subject.call(collection_item) }.to change(collection.collection_items, :count).by(-1)
    end

    context 'when the collection is local' do
      it 'federates a `Remove` activity' do
        subject.call(collection_item)

        expect(ActivityPub::AccountRawDistributionWorker).to have_enqueued_sidekiq_job
      end

      context 'when `revoke` is set to true' do
        it 'revokes the collection item' do
          subject.call(collection_item, revoke: true)

          expect(collection_item.reload).to be_revoked
        end
      end
    end

    context 'when the collection is remote' do
      let(:collection) { Fabricate(:remote_collection) }
      let!(:collection_item) { Fabricate(:collection_item, collection:, state: :accepted) }

      it 'destroys the collection withouth federating anything' do
        expect { subject.call(collection_item, revoke: true) }.to change(collection.collection_items, :count).by(-1)

        expect(ActivityPub::AccountRawDistributionWorker).to_not have_enqueued_sidekiq_job
      end
    end
  end
end
