require 'rails_helper'

RSpec.describe ActivityPub::SynchronizeFollowersService, type: :service do
  let(:actor)          { Fabricate(:account, domain: 'example.com', uri: 'http://example.com/account', inbox_url: 'http://example.com/inbox') }
  let(:alice)          { Fabricate(:account, username: 'alice') }
  let(:bob)            { Fabricate(:account, username: 'bob') }
  let(:eve)            { Fabricate(:account, username: 'eve') }
  let(:mallory)        { Fabricate(:account, username: 'mallory') }
  let(:collection_uri) { 'http://example.com/partial-followers' }

  let(:items) do
    [
      ActivityPub::TagManager.instance.uri_for(alice),
      ActivityPub::TagManager.instance.uri_for(eve),
      ActivityPub::TagManager.instance.uri_for(mallory),
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

  around do |example|
    Sidekiq::Testing.fake! do
      example.run
      Sidekiq::Worker.clear_all
    end
  end

  before do
    alice.follow!(actor)
    bob.follow!(actor)
    mallory.request_follow!(actor)
  end

  shared_examples 'synchronizes followers' do
    before do
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
        .to have_enqueued_sidekiq_job(anything, eve.id, actor.inbox_url) # Send Undo Follow to actor
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

    context 'when the endpoint is a single-page paginated Collection of actor URIs' do
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
        stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
      end

      it_behaves_like 'synchronizes followers'
    end

    context 'when the endpoint is a paginated Collection of actor URIs with a next page' do
      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          type: 'Collection',
          id: collection_uri,
          first: {
            type: 'CollectionPage',
            partOf: collection_uri,
            items: items,
            next: "#{collection_uri}/page2",
          },
        }.with_indifferent_access
      end

      before do
        stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
      end

      it 'does not change followers' do
        expect { subject.call(actor, collection_uri) }
          .to_not(change { actor.followers.reload.reorder(id: :asc).pluck(:id) })
      end
    end
  end
end
