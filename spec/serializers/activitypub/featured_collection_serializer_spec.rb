# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FeaturedCollectionSerializer do
  include RoutingHelper

  subject { serialized_record_json(collection, described_class, adapter: ActivityPub::Adapter) }

  let(:collection) do
    Fabricate(:collection,
              name: 'Incredible people',
              description: 'These are really amazing',
              tag_name: '#people',
              discoverable: false)
  end
  let!(:collection_items) { Fabricate.times(2, :collection_item, collection:) }

  it 'serializes to the expected structure' do
    expect(subject).to include({
      'type' => 'FeaturedCollection',
      'id' => ActivityPub::TagManager.instance.uri_for(collection),
      'name' => 'Incredible people',
      'summary' => 'These are really amazing',
      'attributedTo' => ActivityPub::TagManager.instance.uri_for(collection.account),
      'sensitive' => false,
      'discoverable' => false,
      'url' => account_collection_url(collection.account, collection),
      'topic' => {
        'href' => match(%r{/tags/people$}),
        'type' => 'Hashtag',
        'name' => '#people',
      },
      'totalItems' => 2,
      'orderedItems' => [
        {
          'id' => ActivityPub::TagManager.instance.uri_for(collection_items.first),
          'type' => 'FeaturedItem',
          'featuredObject' => ActivityPub::TagManager.instance.uri_for(collection_items.first.account),
          'featuredObjectType' => 'Person',
          'featureAuthorization' => ap_account_feature_authorization_url(collection_items.first.account_id, collection_items.first),
          'published' => match_api_datetime_format,
        },
        {
          'id' => ActivityPub::TagManager.instance.uri_for(collection_items.last),
          'type' => 'FeaturedItem',
          'featuredObject' => ActivityPub::TagManager.instance.uri_for(collection_items.last.account),
          'featuredObjectType' => 'Person',
          'featureAuthorization' => ap_account_feature_authorization_url(collection_items.last.account_id, collection_items.last),
          'published' => match_api_datetime_format,
        },
      ],
      'published' => match_api_datetime_format,
      'updated' => match_api_datetime_format,
    })
  end

  context 'when a language is set' do
    before do
      collection.language = 'en'
    end

    it 'uses "summaryMap" to include the language' do
      expect(subject).to include({
        'summaryMap' => {
          'en' => 'These are really amazing',
        },
      })

      expect(subject).to_not have_key('summary')
    end
  end

  context 'when not all items are accepted' do
    before do
      collection_items.first.update!(state: :pending)
    end

    it 'only includes accepted items' do
      items = subject['orderedItems']

      expect(subject['totalItems']).to eq 1
      expect(items.size).to eq 1
      expect(items.first['id']).to eq ActivityPub::TagManager.instance.uri_for(collection_items.last)
    end
  end
end
