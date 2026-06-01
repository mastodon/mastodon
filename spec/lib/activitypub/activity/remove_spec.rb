# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::Remove do
  let(:sender) do
    Fabricate(:remote_account,
              featured_collection_url: 'https://example.com/featured',
              collections_url: 'https://example.com/actor/1/featured_collections')
  end

  describe '#perform' do
    subject { described_class.new(json, sender) }

    context 'when removing a pinned status' do
      let(:status) { Fabricate(:status, account: sender) }

      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Remove',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: ActivityPub::TagManager.instance.uri_for(status),
          target: sender.featured_collection_url,
        }.deep_stringify_keys
      end

      before do
        StatusPin.create!(account: sender, status: status)
      end

      it 'removes a pin' do
        expect { subject.perform }
          .to change { sender.pinned?(status) }.to(false)
      end
    end

    context 'when removing a featured tag' do
      let(:tag) { Fabricate(:tag) }

      let(:json) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: 'foo',
          type: 'Remove',
          actor: ActivityPub::TagManager.instance.uri_for(sender),
          object: {
            type: 'Hashtag',
            name: "##{tag.display_name}",
            href: "https://example.com/tags/#{tag.name}",
          },
          target: sender.featured_collection_url,
        }.deep_stringify_keys
      end

      before do
        sender.featured_tags.find_or_create_by!(tag: tag)
      end

      it 'removes a pin' do
        expect { subject.perform }
          .to change { sender.featured_tags.exists?(tag: tag) }.to(false)
      end
    end

    context 'when removing a featured collection' do
      let(:collection) { Fabricate(:remote_collection, account: sender) }
      let(:json) do
        {
          '@context' => 'https://www.w3.org/ns/activitystreams',
          'id' => 'foo',
          'type' => 'Remove',
          'actor' => ActivityPub::TagManager.instance.uri_for(sender),
          'object' => collection.uri,
          'target' => sender.collections_url,
        }
      end

      before do
        Fabricate(:collection_item, collection:, uri: 'https://example.com/featured_items/1')
      end

      it 'deletes the collection' do
        expect { subject.perform }
          .to change(sender.collections, :count).by(-1)
          .and change(CollectionItem, :count).by(-1)
      end
    end

    context 'when removing a featured item' do
      let(:collection) { Fabricate(:remote_collection, account: sender) }
      let(:collection_item) { Fabricate(:collection_item, collection:, uri: 'https://example.com/featured_items/1') }
      let(:json) do
        {
          '@context' => 'https://www.w3.org/ns/activitystreams',
          'id' => 'foo',
          'type' => 'Remove',
          'actor' => ActivityPub::TagManager.instance.uri_for(sender),
          'object' => collection_item.uri,
          'target' => collection.uri,
        }
      end

      before { json }

      it 'deletes the collection item' do
        expect { subject.perform }
          .to change(collection.collection_items, :count).by(-1)
      end
    end
  end
end
