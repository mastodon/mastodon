require 'rails_helper'

RSpec.describe ActivityPub::SynchronizeFollowersService, type: :service do
  let(:actor)          { Fabricate(:account, domain: 'example.com', uri: 'http://example.com/account', inbox_url: 'http://example.com/inbox') }
  let(:alice)          { Fabricate(:account, username: 'alice') }
  let(:bob)            { Fabricate(:account, username: 'bob') }
  let(:eve)            { Fabricate(:account, username: 'eve') }
  let(:collection_uri) { 'http://example.com/partial-followers' }

  let(:items) do
    [
      ActivityPub::TagManager.instance.uri_for(alice),
      ActivityPub::TagManager.instance.uri_for(eve),
    ]
  end

  let(:payload) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      type: 'Collection',
      id: collection_uri,
      items: items,
    }.with_indifferent_access
  end

  subject { described_class.new }

  shared_examples 'synchronizes followers' do
    before do
      alice.follow!(actor)
      bob.follow!(actor)

      allow(ActivityPub::DeliveryWorker).to receive(:perform_async)

      subject.call(actor, collection_uri)
    end

    it 'keeps expected followers' do
      expect(alice.following?(actor)).to be true
    end

    it 'removes local followers not in the remote list' do
      expect(bob.following?(actor)).to be false
    end

    it 'sends an Undo Follow to the actor' do
      expect(ActivityPub::DeliveryWorker).to have_received(:perform_async).with(anything, eve.id, actor.inbox_url)
    end
  end

  describe '#call' do
    context 'when the payload is a Collection with inlined replies' do
      before do
        stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload))
      end

      it_behaves_like 'synchronizes followers'
    end

    context 'when the payload is an OrderedCollection with inlined replies' do
      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          type: 'OrderedCollection',
          id: collection_uri,
          orderedItems: items,
        }.with_indifferent_access
      end

      before do
        stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload))
      end

      it_behaves_like 'synchronizes followers'
    end

    context 'when the payload is a paginated Collection with inlined replies' do
      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          type: 'Collection',
          id: collection_uri,
          first: {
            type: 'CollectionPage',
            partOf: collection_uri,
            items: items,
          }
        }.with_indifferent_access
      end

      before do
        stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload))
      end

      it_behaves_like 'synchronizes followers'
    end
  end
end
