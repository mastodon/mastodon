# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteCollectionService do
  subject { described_class.new }

  let!(:collection) { Fabricate(:collection) }

  before do
    Fabricate.times(2, :collection_item, collection:)
  end

  describe '#call' do
    it 'destroys the collection' do
      expect { subject.call(collection) }.to change(Collection, :count).by(-1)
    end

    it "federates a `Remove` activity to the account's reach plus each collection member" do
      subject.call(collection)

      expect(ActivityPub::AccountRawDistributionWorker).to have_enqueued_sidekiq_job
      expect(ActivityPub::DeliveryWorker).to have_enqueued_sidekiq_job.exactly(2).times
    end
  end
end
