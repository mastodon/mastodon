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

      it 'federates an `Add` activity', feature: :collections_federation do
        subject.call(collection, account)

        expect(ActivityPub::AccountRawDistributionWorker).to have_enqueued_sidekiq_job
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
