# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Activity::Add do
  context 'when the target is the featured collection' do
    let(:sender) { Fabricate(:account, featured_collection_url: 'https://example.com/featured', domain: 'example.com') }
    let(:status) { Fabricate(:status, account: sender, visibility: :private) }

    let(:json) do
      {
        '@context': 'https://www.w3.org/ns/activitystreams',
        id: 'foo',
        type: 'Add',
        actor: ActivityPub::TagManager.instance.uri_for(sender),
        object: ActivityPub::TagManager.instance.uri_for(status),
        target: sender.featured_collection_url,
      }.with_indifferent_access
    end

    describe '#perform' do
      subject { described_class.new(json, sender) }

      it 'creates a pin' do
        subject.perform
        expect(sender.pinned?(status)).to be true
      end

      context 'when status was not known before' do
        let(:service_stub) { instance_double(ActivityPub::FetchRemoteStatusService) }

        let(:json) do
          {
            '@context': 'https://www.w3.org/ns/activitystreams',
            id: 'foo',
            type: 'Add',
            actor: ActivityPub::TagManager.instance.uri_for(sender),
            object: 'https://example.com/unknown',
            target: sender.featured_collection_url,
          }.with_indifferent_access
        end

        before do
          allow(ActivityPub::FetchRemoteStatusService).to receive(:new).and_return(service_stub)
        end

        context 'when there is a local follower' do
          before do
            account = Fabricate(:account)
            account.follow!(sender)
          end

          it 'fetches the status and pins it' do
            allow(service_stub).to receive(:call) do |uri, id: true, on_behalf_of: nil, **|
              expect(uri).to eq 'https://example.com/unknown'
              expect(id).to be true
              expect(on_behalf_of&.following?(sender)).to be true
              status
            end
            subject.perform
            expect(service_stub).to have_received(:call)
            expect(sender.pinned?(status)).to be true
          end
        end

        context 'when there is no local follower' do
          it 'tries to fetch the status' do
            allow(service_stub).to receive(:call) do |uri, id: true, on_behalf_of: nil, **|
              expect(uri).to eq 'https://example.com/unknown'
              expect(id).to be true
              expect(on_behalf_of).to be_nil
              nil
            end
            subject.perform
            expect(service_stub).to have_received(:call)
            expect(sender.pinned?(status)).to be false
          end
        end
      end
    end
  end

  context 'when the target is the `featuredCollections` collection', feature: :collections do
    subject { described_class.new(activity_json, account) }

    let(:account) { Fabricate(:remote_account, collections_url: 'https://example.com/actor/1/featured_collections') }
    let(:featured_collection_json) do
      {
        '@context' => 'https://www.w3.org/ns/activitystreams',
        'id' => 'https://other.example.com/featured_item/1',
        'type' => 'FeaturedCollection',
        'attributedTo' => account.uri,
        'name' => 'Cool people',
        'summary' => 'People you should follow.',
        'totalItems' => 0,
        'sensitive' => false,
        'discoverable' => true,
        'published' => '2026-03-09T15:19:25Z',
      }
    end
    let(:activity_json) do
      {
        '@context' => 'https://www.w3.org/ns/activitystreams',
        'type' => 'Add',
        'actor' => account.uri,
        'target' => 'https://example.com/actor/1/featured_collections',
        'object' => featured_collection_json,
      }
    end
    let(:stubbed_service) do
      instance_double(ActivityPub::ProcessFeaturedCollectionService, call: true)
    end

    before do
      allow(ActivityPub::ProcessFeaturedCollectionService).to receive(:new).and_return(stubbed_service)
    end

    it 'calls the service' do
      subject.perform

      expect(stubbed_service).to have_received(:call).with(account, featured_collection_json)
    end
  end

  context 'when the target is a collection', feature: :collections do
    subject { described_class.new(activity_json, collection.account) }

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
    let(:activity_json) do
      {
        '@context' => 'https://www.w3.org/ns/activitystreams',
        'type' => 'Add',
        'actor' => collection.account.uri,
        'target' => collection.uri,
        'object' => featured_item_json,
      }
    end
    let(:stubbed_service) do
      instance_double(ActivityPub::ProcessFeaturedItemService, call: true)
    end

    before do
      allow(ActivityPub::ProcessFeaturedItemService).to receive(:new).and_return(stubbed_service)
    end

    it 'determines the correct collection and calls the service' do
      subject.perform

      expect(stubbed_service).to have_received(:call).with(collection, featured_item_json)
    end
  end
end
