# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::SynchronizeFollowersService do
  subject { described_class.new }

  let(:actor)          { Fabricate(:account, domain: 'example.com', uri: 'http://example.com/account', inbox_url: 'http://example.com/inbox') }
  let(:alice)          { Fabricate(:account, username: 'alice') }
  let(:bob)            { Fabricate(:account, username: 'bob') }
  let(:eve)            { Fabricate(:account, username: 'eve') }
  let(:mallory)        { Fabricate(:account, username: 'mallory') }
  let(:collection_uri) { 'http://example.com/partial-followers' }

  let(:items) do
    [alice, eve, mallory].map do |account|
      ActivityPub::TagManager.instance.uri_for(account)
    end
  end

  let(:payload) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      type: 'Collection',
      id: collection_uri,
      items: items,
    }.with_indifferent_access
  end

  shared_examples 'synchronizes followers' do
    before do
      alice.follow!(actor)
      bob.follow!(actor)
      mallory.request_follow!(actor)

      allow(ActivityPub::DeliveryWorker).to receive(:perform_async)

      subject.call(actor, collection_uri)
    end

    it 'maintains following records and sends Undo Follow to actor' do
      expect(alice)
        .to be_following(actor) # Keep expected followers
      expect(bob)
        .to_not be_following(actor) # Remove local followers not in remote list
      expect(mallory)
        .to be_following(actor) # Convert follow request to follow when accepted
      expect(ActivityPub::DeliveryWorker)
        .to have_received(:perform_async).with(anything, eve.id, actor.inbox_url) # Send Undo Follow to actor
    end
  end

  describe '#call' do
    context 'when the endpoint is a Collection of actor URIs' do
      before do
        stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
      end

      it_behaves_like 'synchronizes followers'
    end

    context 'when the endpoint is an OrderedCollection of actor URIs' do
      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          type: 'OrderedCollection',
          id: collection_uri,
          orderedItems: items,
        }.with_indifferent_access
      end

      before do
        stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
      end

      it_behaves_like 'synchronizes followers'
    end

    context 'when the endpoint is a paginated Collection of actor URIs' do
      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          type: 'Collection',
          id: collection_uri,
          first: {
            type: 'CollectionPage',
            partOf: collection_uri,
            items: items,
          },
        }.with_indifferent_access
      end

      before do
        stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
      end

      it_behaves_like 'synchronizes followers'
    end
  end
end
