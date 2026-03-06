# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FeaturedItemSerializer do
  include RoutingHelper

  subject { serialized_record_json(collection_item, described_class, adapter: ActivityPub::Adapter) }

  let(:collection_item) { Fabricate(:collection_item) }

  context 'when a local account is featured' do
    it 'serializes to the expected structure' do
      expect(subject).to include({
        'type' => 'FeaturedItem',
        'id' => ActivityPub::TagManager.instance.uri_for(collection_item),
        'featuredObject' => ActivityPub::TagManager.instance.uri_for(collection_item.account),
        'featuredObjectType' => 'Person',
        'featureAuthorization' => ap_account_feature_authorization_url(collection_item.account_id, collection_item),
      })
    end
  end

  context 'when a remote account is featured' do
    let(:collection) { Fabricate(:collection) }
    let(:account) { Fabricate(:remote_account) }
    let(:collection_item) { Fabricate(:collection_item, collection:, account:, approval_uri: 'https://example.com/auth/1') }

    it 'serializes to the expected structure' do
      expect(subject).to include({
        'type' => 'FeaturedItem',
        'id' => ActivityPub::TagManager.instance.uri_for(collection_item),
        'featuredObject' => ActivityPub::TagManager.instance.uri_for(collection_item.account),
        'featuredObjectType' => 'Person',
        'featureAuthorization' => 'https://example.com/auth/1',
      })
    end
  end
end
