# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::AcceptFeatureRequestSerializer do
  include RoutingHelper

  subject { serialized_record_json(record, described_class, adapter: ActivityPub::Adapter) }

  describe 'serializing an object' do
    let(:collection) { Fabricate(:remote_collection) }
    let(:record) do
      Fabricate(:collection_item,
                collection:,
                uri: 'https://example.com/featured_items/1',
                activity_uri: 'https://example.com/feature_requests/1',
                state: :accepted)
    end
    let(:tag_manager) { ActivityPub::TagManager.instance }

    it 'returns expected attributes' do
      expect(subject)
        .to include(
          'id' => match("#accepts/feature_requests/#{record.id}"),
          'type' => 'Accept',
          'actor' => tag_manager.uri_for(record.account),
          'to' => tag_manager.uri_for(collection.account),
          'object' => 'https://example.com/feature_requests/1',
          'result' => ap_account_feature_authorization_url(record.account_id, record)
        )
    end
  end
end
