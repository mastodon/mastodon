# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::DeleteFeatureAuthorizationSerializer do
  include RoutingHelper

  subject { serialized_record_json(collection_item, described_class, adapter: ActivityPub::Adapter) }

  describe 'serializing an object' do
    let(:collection) { Fabricate(:remote_collection) }
    let(:collection_item) { Fabricate(:collection_item, collection:, uri: 'https://example.com') }

    it 'returns expected json structure' do
      expect(subject)
        .to include({
          'type' => 'Delete',
          'to' => ['https://www.w3.org/ns/activitystreams#Public'],
          'actor' => ActivityPub::TagManager.instance.uri_for(collection_item.account),
          'object' => a_hash_including({
            'type' => 'FeatureAuthorization',
            'id' => ap_account_feature_authorization_url(collection_item.account_id, collection_item),
          }),
        })
    end
  end
end
