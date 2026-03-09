# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::ProcessFeaturedItemService do
  subject { described_class.new }

  let(:collection) { Fabricate(:remote_collection) }
  let(:featured_item_json) do
    {
      '@context' => 'https://www.w3.org/ns/activitystreams',
      'id' => 'https://other.example.com/featured_item/1',
      'type' => 'FeaturedItem',
      'featuredObject' => 'https://example.com/actor/1',
      'featuredObjectType' => 'Person',
      'featureAuthorization' => 'https://example.com/auth/1',
    }
  end
  let(:stubbed_service) do
    instance_double(ActivityPub::VerifyFeaturedItemService, call: true)
  end

  before do
    allow(ActivityPub::VerifyFeaturedItemService).to receive(:new).and_return(stubbed_service)
  end

  context 'when the collection item is inlined' do
    it 'creates and verifies the item' do
      expect { subject.call(collection, featured_item_json) }.to change(collection.collection_items, :count).by(1)

      expect(stubbed_service).to have_received(:call)

      new_item = collection.collection_items.last
      expect(new_item.object_uri).to eq 'https://example.com/actor/1'
      expect(new_item.approval_uri).to eq 'https://example.com/auth/1'
    end
  end

  context 'when only the id of the collection item is given' do
    let(:featured_item_request) do
      stub_request(:get, featured_item_json['id'])
        .to_return_json(
          status: 200,
          body: featured_item_json,
          headers: { 'Content-Type' => 'application/activity+json' }
        )
    end

    before do
      featured_item_request
    end

    it 'fetches the collection item' do
      expect { subject.call(collection, featured_item_json['id']) }.to change(collection.collection_items, :count).by(1)

      expect(featured_item_request).to have_been_requested

      new_item = collection.collection_items.last
      expect(new_item.object_uri).to eq 'https://example.com/actor/1'
      expect(new_item.approval_uri).to eq 'https://example.com/auth/1'
    end
  end
end
