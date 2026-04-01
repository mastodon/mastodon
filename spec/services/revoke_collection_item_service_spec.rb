# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RevokeCollectionItemService do
  subject { described_class.new }

  let(:collection_item) { Fabricate(:collection_item) }

  it 'revokes the collection item and sends a Delete activity' do
    expect { subject.call(collection_item) }
      .to change { collection_item.reload.state }.from('accepted').to('revoked')
  end

  context 'when the collection is remote' do
    let(:account) { Fabricate(:remote_account, inbox_url: 'https://example.com/actor/1/inbox') }
    let(:collection) { Fabricate(:remote_collection, account:) }
    let(:collection_item) { Fabricate(:collection_item, collection:, uri: 'https://example.com') }

    it 'federates a `Delete` activity' do
      subject.call(collection_item)

      expect(ActivityPub::DeliveryWorker).to have_enqueued_sidekiq_job.with(instance_of(String), collection_item.account_id, 'https://example.com/actor/1/inbox')
      expect(ActivityPub::AccountRawDistributionWorker).to have_enqueued_sidekiq_job
    end
  end
end
