# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::SynchronizeFollowersService do
  subject { described_class.new }

  let(:actor)          { Fabricate(:account, domain: 'example.com', uri: 'http://example.com/account', inbox_url: 'http://example.com/inbox') }
  let(:alice)          { Fabricate(:account, username: 'alice', id_scheme: :numeric_ap_id) }
  let(:bob)            { Fabricate(:account, username: 'bob') }
  let(:eve)            { Fabricate(:account, username: 'eve') }
  let(:mallory)        { Fabricate(:account, username: 'mallory') }
  let(:collection_uri) { 'https://example.com/partial-followers' }

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

  before do
    alice.follow!(actor)
    bob.follow!(actor)
    mallory.request_follow!(actor)
  end

  shared_examples 'synchronizes followers' do
    before do
      subject.call(actor, collection_uri, expected_digest)
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
    let(:expected_digest) { nil }

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
          },
        }.with_indifferent_access
      end

      before do
        stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
      end

      it_behaves_like 'synchronizes followers'
    end

    context 'when the endpoint is a paginated Collection of actor URIs split across multiple pages' do
      before do
        stub_request(:get, 'https://example.com/partial-followers')
          .to_return(status: 200, headers: { 'Content-Type': 'application/activity+json' }, body: Oj.dump({
            '@context': 'https://www.w3.org/ns/activitystreams',
            type: 'Collection',
            id: 'https://example.com/partial-followers',
            first: 'https://example.com/partial-followers/1',
          }))

        stub_request(:get, 'https://example.com/partial-followers/1')
          .to_return(status: 200, headers: { 'Content-Type': 'application/activity+json' }, body: Oj.dump({
            '@context': 'https://www.w3.org/ns/activitystreams',
            type: 'CollectionPage',
            id: 'https://example.com/partial-followers/1',
            partOf: 'https://example.com/partial-followers',
            next: 'https://example.com/partial-followers/2',
            items: [alice, eve].map { |account| ActivityPub::TagManager.instance.uri_for(account) },
          }))

        stub_request(:get, 'https://example.com/partial-followers/2')
          .to_return(status: 200, headers: { 'Content-Type': 'application/activity+json' }, body: Oj.dump({
            '@context': 'https://www.w3.org/ns/activitystreams',
            type: 'CollectionPage',
            id: 'https://example.com/partial-followers/2',
            partOf: 'https://example.com/partial-followers',
            items: ActivityPub::TagManager.instance.uri_for(mallory),
          }))
      end

      it_behaves_like 'synchronizes followers'
    end

    context 'when the endpoint is a paginated Collection of actor URIs split across, but one page errors out' do
      before do
        stub_request(:get, 'https://example.com/partial-followers')
          .to_return(status: 200, headers: { 'Content-Type': 'application/activity+json' }, body: Oj.dump({
            '@context': 'https://www.w3.org/ns/activitystreams',
            type: 'Collection',
            id: 'https://example.com/partial-followers',
            first: 'https://example.com/partial-followers/1',
          }))

        stub_request(:get, 'https://example.com/partial-followers/1')
          .to_return(status: 200, headers: { 'Content-Type': 'application/activity+json' }, body: Oj.dump({
            '@context': 'https://www.w3.org/ns/activitystreams',
            type: 'CollectionPage',
            id: 'https://example.com/partial-followers/1',
            partOf: 'https://example.com/partial-followers',
            next: 'https://example.com/partial-followers/2',
            items: [mallory].map { |account| ActivityPub::TagManager.instance.uri_for(account) },
          }))

        stub_request(:get, 'https://example.com/partial-followers/2')
          .to_return(status: 404)
      end

      it 'confirms pending follow request but does not remove extra followers' do
        previous_follower_ids = actor.followers.pluck(:id)

        subject.call(actor, collection_uri)

        expect(previous_follower_ids - actor.followers.reload.pluck(:id))
          .to be_empty
        expect(mallory)
          .to be_following(actor)
      end
    end

    context 'when the endpoint is a paginated Collection of actor URIs with more pages than we allow' do
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
        stub_const('ActivityPub::SynchronizeFollowersService::MAX_COLLECTION_PAGES', 1)
        stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
      end

      it 'confirms pending follow request but does not remove extra followers' do
        previous_follower_ids = actor.followers.pluck(:id)

        subject.call(actor, collection_uri)

        expect(previous_follower_ids - actor.followers.reload.pluck(:id))
          .to be_empty
        expect(mallory)
          .to be_following(actor)
      end
    end

    context 'when passing a matching expected_digest' do
      let(:expected_digest) do
        digest = "\x00" * 32

        items.each do |uri|
          Xorcist.xor!(digest, Digest::SHA256.digest(uri))
        end

        digest.unpack1('H*')
      end

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
            },
          }.with_indifferent_access
        end

        before do
          stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
        end

        it_behaves_like 'synchronizes followers'
      end
    end

    context 'when passing a non-matching expected_digest' do
      let(:expected_digest) { '123456789' }

      context 'when the endpoint is a Collection of actor URIs' do
        before do
          stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
        end

        it 'does not remove followers' do
          follower_ids = actor.followers.reload.pluck(:id)

          subject.call(actor, collection_uri, expected_digest)

          expect(follower_ids - actor.followers.reload.pluck(:id)).to be_empty
        end
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

        it 'does not remove followers' do
          follower_ids = actor.followers.reload.pluck(:id)

          subject.call(actor, collection_uri, expected_digest)

          expect(follower_ids - actor.followers.reload.pluck(:id)).to be_empty
        end
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
            },
          }.with_indifferent_access
        end

        before do
          stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
        end

        it 'does not remove followers' do
          follower_ids = actor.followers.reload.pluck(:id)

          subject.call(actor, collection_uri, expected_digest)

          expect(follower_ids - actor.followers.reload.pluck(:id)).to be_empty
        end
      end
    end
  end
end
