# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::ProcessFeaturedItemService do
  include RoutingHelper

  subject { described_class.new }

  let(:collection) { Fabricate(:remote_collection, uri: 'https://other.example.com/collection/1') }
  let(:position) { 3 }
  let(:featured_object_uri) { 'https://example.com/actor/1' }
  let(:feature_authorization_uri) { 'https://example.com/auth/1' }
  let(:featured_item_json) do
    {
      '@context' => 'https://www.w3.org/ns/activitystreams',
      'id' => 'https://other.example.com/featured_item/1',
      'type' => 'FeaturedItem',
      'featuredObject' => featured_object_uri,
      'featuredObjectType' => 'Person',
      'featureAuthorization' => feature_authorization_uri,
    }
  end
  let(:stubbed_service) do
    instance_double(ActivityPub::VerifyFeaturedItemService, call: true)
  end

  before do
    allow(ActivityPub::VerifyFeaturedItemService).to receive(:new).and_return(stubbed_service)
  end

  shared_examples 'non-matching URIs' do
    context "when the item's URI does not match the collection's" do
      let(:collection) { Fabricate(:remote_collection) }

      it 'does not create a collection item and returns `nil`' do
        expect do
          expect(subject.call(collection, object, position:)).to be_nil
        end.to_not change(CollectionItem, :count)
      end
    end
  end

  context 'when the collection item is inlined' do
    let(:object) { featured_item_json }

    it_behaves_like 'non-matching URIs'

    context 'when item does not yet exist' do
      context 'when a position is given' do
        it 'creates and verifies the item' do
          expect { subject.call(collection, object, position:) }.to change(collection.collection_items, :count).by(1)

          expect(stubbed_service).to have_received(:call)

          new_item = collection.collection_items.last
          expect(new_item.object_uri).to eq 'https://example.com/actor/1'
          expect(new_item.approval_uri).to be_nil
          expect(new_item.position).to eq 3
        end
      end

      context 'when no position is given' do
        it 'creates the item' do
          expect { subject.call(collection, object) }.to change(collection.collection_items, :count).by(1)
          new_item = collection.collection_items.last

          expect(new_item.position).to eq 1
        end
      end
    end

    context 'when item exists at a different position' do
      let!(:collection_item) do
        Fabricate(:collection_item, collection:, uri: featured_item_json['id'], position: 2)
      end

      it 'updates the position' do
        expect { subject.call(collection, object, position:) }.to_not change(collection.collection_items, :count)

        expect(collection_item.reload.position).to eq 3
      end
    end

    context 'when an item exists for a local featured account' do
      let!(:collection_item) do
        Fabricate(:collection_item, collection:, state: :accepted)
      end
      let(:featured_object_uri) { ActivityPub::TagManager.instance.uri_for(collection_item.account) }
      let(:feature_authorization_uri) { ap_account_feature_authorization_url(collection_item.account_id, collection_item) }

      it 'updates the URI of the existing record' do
        expect { subject.call(collection, object, position:) }.to_not change(collection.collection_items, :count)
        expect(collection_item.reload.uri).to eq 'https://other.example.com/featured_item/1'
      end
    end
  end

  context 'when only the id of the collection item is given' do
    let(:object) { featured_item_json['id'] }
    let(:featured_item_request) do
      stub_request(:get, object)
        .to_return_json(
          status: 200,
          body: featured_item_json,
          headers: { 'Content-Type' => 'application/activity+json' }
        )
    end

    before do
      featured_item_request
    end

    it_behaves_like 'non-matching URIs'

    it 'fetches the collection item' do
      expect { subject.call(collection, object, position:) }.to change(collection.collection_items, :count).by(1)

      expect(featured_item_request).to have_been_requested

      new_item = collection.collection_items.last
      expect(new_item.object_uri).to eq 'https://example.com/actor/1'
      expect(new_item.approval_uri).to be_nil
    end
  end
end
