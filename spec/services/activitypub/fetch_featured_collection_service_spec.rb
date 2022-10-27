require 'rails_helper'

RSpec.describe ActivityPub::FetchFeaturedCollectionService, type: :service do
  let(:actor) { Fabricate(:account, domain: 'example.com', uri: 'https://example.com/account', featured_collection_url: 'https://example.com/account/pinned') }

  let!(:known_status) { Fabricate(:status, account: actor, uri: 'https://example.com/account/pinned/1') }

  let(:status_json_1) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      type: 'Note',
      id: 'https://example.com/account/pinned/1',
      content: 'foo',
      attributedTo: actor.uri,
      to: 'https://www.w3.org/ns/activitystreams#Public',
    }
  end

  let(:status_json_2) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      type: 'Note',
      id: 'https://example.com/account/pinned/2',
      content: 'foo',
      attributedTo: actor.uri,
      to: 'https://www.w3.org/ns/activitystreams#Public',
    }
  end

  let(:status_json_4) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      type: 'Note',
      id: 'https://example.com/account/pinned/4',
      content: 'foo',
      attributedTo: actor.uri,
      to: 'https://www.w3.org/ns/activitystreams#Public',
    }
  end

  let(:items) do
    [
      'https://example.com/account/pinned/1', # known
      status_json_2, # unknown inlined
      'https://example.com/account/pinned/3', # unknown unreachable
      'https://example.com/account/pinned/4', # unknown reachable
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

  subject { described_class.new }

  shared_examples 'sets pinned posts' do
    before do
      stub_request(:get, 'https://example.com/account/pinned/1').to_return(status: 200, body: Oj.dump(status_json_1))
      stub_request(:get, 'https://example.com/account/pinned/2').to_return(status: 200, body: Oj.dump(status_json_2))
      stub_request(:get, 'https://example.com/account/pinned/3').to_return(status: 404)
      stub_request(:get, 'https://example.com/account/pinned/4').to_return(status: 200, body: Oj.dump(status_json_4))

      subject.call(actor, note: true, hashtag: false)
    end

    it 'sets expected posts as pinned posts' do
      expect(actor.pinned_statuses.pluck(:uri)).to match_array ['https://example.com/account/pinned/1', 'https://example.com/account/pinned/2', 'https://example.com/account/pinned/4']
    end
  end

  describe '#call' do
    context 'when the endpoint is a Collection' do
      before do
        stub_request(:get, actor.featured_collection_url).to_return(status: 200, body: Oj.dump(payload))
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
        stub_request(:get, actor.featured_collection_url).to_return(status: 200, body: Oj.dump(payload))
      end

      it_behaves_like 'sets pinned posts'
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
          }
        }.with_indifferent_access
      end

      before do
        stub_request(:get, actor.featured_collection_url).to_return(status: 200, body: Oj.dump(payload))
      end

      it_behaves_like 'sets pinned posts'
    end
  end
end
