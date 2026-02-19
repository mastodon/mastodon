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

    it 'federates a `Remove` activity', feature: :collections_federation do
      subject.call(collection_item)

      expect(ActivityPub::AccountRawDistributionWorker).to have_enqueued_sidekiq_job
    end
  end
end
