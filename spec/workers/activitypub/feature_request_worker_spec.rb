# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FeatureRequestWorker do
  subject { described_class.new }

  let(:account) { Fabricate(:account, inbox_url: 'http://example.com', domain: 'example.com') }
  let(:collection_owner) { Fabricate(:account) }
  let(:collection) { Fabricate(:collection, account: collection_owner) }
  let(:collection_item) { Fabricate(:collection_item, collection:, account:) }

  describe '#perform' do
    it 'sends the expected `FeatureRequest` activity' do
      subject.perform(collection_item.id)

      expect(ActivityPub::DeliveryWorker)
        .to have_enqueued_sidekiq_job(expected_json, collection_owner.id, 'http://example.com', {})
    end

    def expected_json
      match_json_values(
        id: a_string_matching(/^http/),
        type: 'FeatureRequest',
        object: ActivityPub::TagManager.instance.uri_for(account),
        instrument: ActivityPub::TagManager.instance.uri_for(collection_item.collection)
      )
    end
  end
end
