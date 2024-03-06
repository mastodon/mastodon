# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FetchRepliesService, type: :service do
  subject { described_class.new }

  let(:actor)          { Fabricate(:account, domain: 'example.com', uri: 'http://example.com/account') }
  let(:status)         { Fabricate(:status, account: actor) }
  let(:collection_uri) { 'http://example.com/replies/1' }

  let(:items) do
    [
      'http://example.com/self-reply-1',
      'http://example.com/self-reply-2',
      'http://example.com/self-reply-3',
      'http://other.com/other-reply-1',
      'http://other.com/other-reply-2',
      'http://other.com/other-reply-3',
      'http://example.com/self-reply-4',
      'http://example.com/self-reply-5',
      'http://example.com/self-reply-6',
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

  describe '#call' do
    context 'when the payload is a Collection with inlined replies' do
      context 'when there is a single reply, with the array compacted away' do
        let(:items) { 'http://example.com/self-reply-1' }

        it 'queues the expected worker' do
          allow(FetchReplyWorker).to receive(:push_bulk)

          subject.call(status, payload)

          expect(FetchReplyWorker).to have_received(:push_bulk).with(['http://example.com/self-reply-1'])
        end
      end

      context 'when passing the collection itself' do
        it 'spawns workers for up to 5 replies on the same server' do
          allow(FetchReplyWorker).to receive(:push_bulk)

          subject.call(status, payload)

          expect(FetchReplyWorker).to have_received(:push_bulk).with(['http://example.com/self-reply-1', 'http://example.com/self-reply-2', 'http://example.com/self-reply-3', 'http://example.com/self-reply-4', 'http://example.com/self-reply-5'])
        end
      end

      context 'when passing the URL to the collection' do
        before do
          stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
        end

        it 'spawns workers for up to 5 replies on the same server' do
          allow(FetchReplyWorker).to receive(:push_bulk)

          subject.call(status, collection_uri)

          expect(FetchReplyWorker).to have_received(:push_bulk).with(['http://example.com/self-reply-1', 'http://example.com/self-reply-2', 'http://example.com/self-reply-3', 'http://example.com/self-reply-4', 'http://example.com/self-reply-5'])
        end
      end
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

      context 'when passing the collection itself' do
        it 'spawns workers for up to 5 replies on the same server' do
          allow(FetchReplyWorker).to receive(:push_bulk)

          subject.call(status, payload)

          expect(FetchReplyWorker).to have_received(:push_bulk).with(['http://example.com/self-reply-1', 'http://example.com/self-reply-2', 'http://example.com/self-reply-3', 'http://example.com/self-reply-4', 'http://example.com/self-reply-5'])
        end
      end

      context 'when passing the URL to the collection' do
        before do
          stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
        end

        it 'spawns workers for up to 5 replies on the same server' do
          allow(FetchReplyWorker).to receive(:push_bulk)

          subject.call(status, collection_uri)

          expect(FetchReplyWorker).to have_received(:push_bulk).with(['http://example.com/self-reply-1', 'http://example.com/self-reply-2', 'http://example.com/self-reply-3', 'http://example.com/self-reply-4', 'http://example.com/self-reply-5'])
        end
      end
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
          },
        }.with_indifferent_access
      end

      context 'when passing the collection itself' do
        it 'spawns workers for up to 5 replies on the same server' do
          allow(FetchReplyWorker).to receive(:push_bulk)

          subject.call(status, payload)

          expect(FetchReplyWorker).to have_received(:push_bulk).with(['http://example.com/self-reply-1', 'http://example.com/self-reply-2', 'http://example.com/self-reply-3', 'http://example.com/self-reply-4', 'http://example.com/self-reply-5'])
        end
      end

      context 'when passing the URL to the collection' do
        before do
          stub_request(:get, collection_uri).to_return(status: 200, body: Oj.dump(payload), headers: { 'Content-Type': 'application/activity+json' })
        end

        it 'spawns workers for up to 5 replies on the same server' do
          allow(FetchReplyWorker).to receive(:push_bulk)

          subject.call(status, collection_uri)

          expect(FetchReplyWorker).to have_received(:push_bulk).with(['http://example.com/self-reply-1', 'http://example.com/self-reply-2', 'http://example.com/self-reply-3', 'http://example.com/self-reply-4', 'http://example.com/self-reply-5'])
        end
      end
    end
  end
end
