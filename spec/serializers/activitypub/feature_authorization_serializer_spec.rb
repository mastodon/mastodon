# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FeatureAuthorizationSerializer do
  include RoutingHelper

  subject { serialized_record_json(collection_item, described_class, adapter: ActivityPub::Adapter) }

  describe 'serializing an object' do
    let(:collection_item) { Fabricate(:collection_item) }
    let(:tag_manager) { ActivityPub::TagManager.instance }

    it 'returns the expected json structure' do
      expect(subject)
        .to include(
          'type' => 'FeatureAuthorization',
          'id' => ap_account_feature_authorization_url(collection_item.account_id, collection_item),
          'interactionTarget' => tag_manager.uri_for(collection_item.account),
          'interactingObject' => tag_manager.uri_for(collection_item.collection)
        )
    end
  end
end
