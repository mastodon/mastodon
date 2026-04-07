# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AddAccountToCollectionService do
  subject { described_class.new }

  let(:collection) { Fabricate.create(:collection) }

  describe '#call' do
    context 'when given a featurable account' do
      let(:account) { Fabricate(:account) }

      it 'creates a new CollectionItem in the `accepted` state' do
        expect do
          subject.call(collection, account)
        end.to change(collection.collection_items, :count).by(1)

        new_item = collection.collection_items.last
        expect(new_item.state).to eq 'accepted'
        expect(new_item.account).to eq account
      end

      context 'when the account is local' do
        it 'federates an `Add` activity and schedules a notification' do
          subject.call(collection, account)

          expect(ActivityPub::AccountRawDistributionWorker)
            .to have_enqueued_sidekiq_job
            .with(anything, collection.account_id)
          expect(LocalNotificationWorker)
            .to have_enqueued_sidekiq_job
            .with(account.id, anything, 'CollectionItem', 'added_to_collection')
        end
      end

      context 'when the account is remote' do
        let(:account) { Fabricate(:remote_account, feature_approval_policy: (0b10 << 16)) }

        it 'marks the item as `pending` and federates a `FeatureRequest` activity' do
          subject.call(collection, account)

          new_item = collection.collection_items.last
          expect(new_item).to be_pending

          expect(ActivityPub::FeatureRequestWorker).to have_enqueued_sidekiq_job
        end
      end
    end

    context 'when given an account that is not featureable' do
      let(:account) { Fabricate(:account, discoverable: false) }

      it 'raises an error' do
        expect do
          subject.call(collection, account)
        end.to raise_error(Mastodon::NotPermittedError)
      end
    end
  end
end
