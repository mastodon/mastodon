# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::AccountBackfillService do
  subject { described_class.new }

  before do
    stub_const('ActivityPub::AccountBackfillService::ENABLED', true)
  end

  let!(:account) { Fabricate(:account, domain: 'other.com', outbox_url: 'http://other.com/alice/outbox') }

  let!(:outbox) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',

      id: 'http://other.com/alice/outbox',
      type: 'OrderedCollection',
      first: 'http://other.com/alice/outbox?page=true',
    }.with_indifferent_access
  end

  let!(:items) do
    [
      {
        '@context': 'https://www.w3.org/ns/activitystreams',
        id: 'https://other.com/alice/1234',
        to: ['https://www.w3.org/ns/activitystreams#Public'],
        cc: ['https://other.com/alice/followers'],
        type: 'Note',
        content: 'Lorem ipsum',
        attributedTo: 'http://other.com/alice',
      },
      'https://other.com/alice/5678',
    ]
  end

  let!(:outbox_page) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'http://example.com/alice/outbox?page=true',
      type: 'OrderedCollectionPage',
      orderedItems: items,
    }
  end

  describe '#call' do
    before do
      stub_request(:get, 'http://other.com/alice/outbox').to_return(status: 200, body: Oj.dump(outbox), headers: { 'Content-Type': 'application/activity+json' })
      stub_request(:get, 'http://other.com/alice/outbox?page=true').to_return(status: 200, body: Oj.dump(outbox_page), headers: { 'Content-Type': 'application/activity+json' })
      stub_const('ActivityPub::AccountBackfillService::ENABLED', true)
    end

    it 'fetches the items in the outbox' do
      allow(FetchReplyWorker).to receive(:push_bulk)
      got_items = subject.call(account)
      expect(got_items[0].deep_symbolize_keys).to eq(items[0])
      expect(got_items[1]).to eq(items[1])
      expect(FetchReplyWorker).to have_received(:push_bulk).with([items[0].stringify_keys, items[1]])
    end

    context 'with followers-only and private statuses' do
      let!(:items) do
        [
          {
            '@context': 'https://www.w3.org/ns/activitystreams',
            id: 'https://other.com/alice/public',
            type: 'Note',
            to: ['https://www.w3.org/ns/activitystreams#Public'],
            cc: ['https://other.com/alice/followers'],
            content: 'Lorem ipsum',
            attributedTo: 'http://other.com/alice',
          },
          {
            '@context': 'https://www.w3.org/ns/activitystreams',
            id: 'https://other.com/alice/unlisted',
            to: ['https://other.com/alice/followers'],
            cc: ['https://www.w3.org/ns/activitystreams#Public'],
            type: 'Note',
            content: 'Lorem ipsum',
            attributedTo: 'http://other.com/alice',
          },
          {
            '@context': 'https://www.w3.org/ns/activitystreams',
            id: 'https://other.com/alice/followers-only',
            to: ['https://other.com/alice/followers'],
            type: 'Note',
            content: 'Lorem ipsum',
            attributedTo: 'http://other.com/alice',
          },
          {
            '@context': 'https://www.w3.org/ns/activitystreams',
            id: 'https://other.com/alice/dm',
            to: ['https://other.com/alice/followers'],
            type: 'Note',
            content: 'Lorem ipsum',
            attributedTo: 'http://other.com/alice',
          },
        ]
      end

      it 'only processes public and unlisted statuses' do
        allow(FetchReplyWorker).to receive(:push_bulk)
        got_items = subject.call(account)
        expect(got_items.length).to eq(2)
        expect(got_items[0].deep_symbolize_keys).to eq(items[0])
        expect(got_items[1].deep_symbolize_keys).to eq(items[1])
        expect(FetchReplyWorker).to have_received(:push_bulk).with([items[0].stringify_keys, items[1].stringify_keys])
      end
    end

    context 'when disabled' do
      before { stub_const('ActivityPub::AccountBackfillService::ENABLED', false) }

      it 'does not backfill' do
        allow(FetchReplyWorker).to receive(:push_bulk)
        got_items = subject.call(account)
        expect(got_items).to be_nil
        expect(FetchReplyWorker).to_not have_received(:push_bulk)
      end
    end
  end
end
