# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FetchFeaturedCollectionService, type: :service do
  subject { described_class.new }

  let(:actor) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/account', featured_collection_url: 'https://example.com/account/pinned') }

  let!(:known_status) { Fabricate(:status, account: actor, uri: 'https://example.com/account/pinned/1') }

  let(:status_json_pinned_known) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      type: 'Note',
      id: 'https://example.com/account/pinned/known',
      content: 'foo',
      attributedTo: actor.uri,
      to: 'https://www.w3.org/ns/activitystreams#Public',
    }
  end

  let(:status_json_pinned_unknown_inlined) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      type: 'Note',
      id: 'https://example.com/account/pinned/unknown-inlined',
      content: 'foo',
      attributedTo: actor.uri,
      to: 'https://www.w3.org/ns/activitystreams#Public',
    }
  end

  let(:status_json_pinned_unknown_reachable) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      type: 'Note',
      id: 'https://example.com/account/pinned/unknown-reachable',
      content: 'foo',
      attributedTo: actor.uri,
      to: 'https://www.w3.org/ns/activitystreams#Public',
    }
  end

  let(:featured_with_null) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'https://example.com/account/collections/featured',
      totalItems: 0,
      type: 'OrderedCollection',
    }
  end

  let(:items) do
    [
      'https://example.com/account/pinned/known', # known
      status_json_pinned_unknown_inlined, # unknown inlined
      'https://example.com/account/pinned/unknown-unreachable', # unknown unreachable
      'https://example.com/account/pinned/unknown-reachable', # unknown reachable
      'https://example.com/account/collections/featured', # featured with null
    ]
  end

  let(:payload) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      type: 'Collection',
      id: actor.featured_collection_url,
      items: items,
    }.with_indifferent_access
  end

  shared_examples 'sets pinned posts' do
    before do
      stub_request(:get, 'https://example.com/account/pinned/known').to_return(status: 200, body: Oj.dump(status_json_pinned_known), headers: { 'Content-Type': 'application/activity+json' })
      stub_request(:get, 'https://example.com/account/pinned/unknown-inlined').to_return(status: 200, body: Oj.dump(status_json_pinned_unknown_inlined), headers: { 'Content-Type': 'application/activity+json' })
      stub_request(:get, 'https://example.com/account/pinned/unknown-unreachable').to_return(status: 404)
      stub_request(:get, 'https://example.com/account/pinned/unknown-reachable').to_return(status: 200, body: Oj.dump(status_json_pinned_unknown_reachable), headers: { 'Content-Type': 'application/activity+json' })
      stub_request(:get, 'https://example.com/account/collections/featured').to_return(status: 200, body: Oj.dump(featured_with_null), headers: { 'Content-Type': 'application/activity+json' })

      subject.call(actor, note: true, hashtag: false)
    end

    it 'sets expected posts as pinned posts' do
      expect(actor.pinned_statuses.pluck(:uri)).to contain_exactly(
        'https://example.com/account/pinned/known',
        'https://example.com/account/pinned/unknown-inlined',
        'https://example.com/account/pinned/unknown-reachable'
      )
      expect(actor.pinned_statuses).to_not include(known_status)
    end
  end

  describe '#call' do
    context 'when the endpoint is a Collection' do
      before do
        stub_request(:get, actor.featured_collection_url).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
      end

      it_behaves_like 'sets pinned posts'
    end

    context 'when the endpoint is an OrderedCollection' do
      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          type: 'OrderedCollection',
          id: actor.featured_collection_url,
          orderedItems: items,
        }.with_indifferent_access
      end

      before do
        stub_request(:get, actor.featured_collection_url).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
      end

      it_behaves_like 'sets pinned posts'

      context 'when there is a single item, with the array compacted away' do
        let(:items) { 'https://example.com/account/pinned/unknown-reachable' }

        before do
          stub_request(:get, 'https://example.com/account/pinned/unknown-reachable').to_return(status: 200, body: Oj.dump(status_json_pinned_unknown_reachable), headers: { 'Content-Type': 'application/activity+json' })
          subject.call(actor, note: true, hashtag: false)
        end

        it 'sets expected posts as pinned posts' do
          expect(actor.pinned_statuses.pluck(:uri)).to contain_exactly(
            'https://example.com/account/pinned/unknown-reachable'
          )
        end
      end
    end

    context 'when the endpoint is a paginated Collection' do
      let(:payload) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          type: 'Collection',
          id: actor.featured_collection_url,
          first: {
            type: 'CollectionPage',
            partOf: actor.featured_collection_url,
            items: items,
          },
        }.with_indifferent_access
      end

      before do
        stub_request(:get, actor.featured_collection_url).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
      end

      it_behaves_like 'sets pinned posts'

      context 'when there is a single item, with the array compacted away' do
        let(:items) { 'https://example.com/account/pinned/unknown-reachable' }

        before do
          stub_request(:get, 'https://example.com/account/pinned/unknown-reachable').to_return(status: 200, body: Oj.dump(status_json_pinned_unknown_reachable), headers: { 'Content-Type': 'application/activity+json' })
          subject.call(actor, note: true, hashtag: false)
        end

        it 'sets expected posts as pinned posts' do
          expect(actor.pinned_statuses.pluck(:uri)).to contain_exactly(
            'https://example.com/account/pinned/unknown-reachable'
          )
        end
      end
    end
  end
end
