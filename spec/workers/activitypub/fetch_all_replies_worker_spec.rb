# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FetchAllRepliesWorker do
  subject { described_class.new }

  let(:top_items) do
    [
      'http://example.com/self-reply-1',
      'http://other.com/other-reply-2',
      'http://example.com/self-reply-3',
    ]
  end

  let(:top_items_paged) do
    [
      'http://example.com/self-reply-4',
      'http://other.com/other-reply-5',
      'http://example.com/self-reply-6',
    ]
  end

  let(:nested_items) do
    [
      'http://example.com/nested-self-reply-1',
      'http://other.com/nested-other-reply-2',
      'http://example.com/nested-self-reply-3',
    ]
  end

  let(:nested_items_paged) do
    [
      'http://example.com/nested-self-reply-4',
      'http://other.com/nested-other-reply-5',
      'http://example.com/nested-self-reply-6',
    ]
  end

  let(:all_items) do
    top_items + top_items_paged + nested_items + nested_items_paged
  end

  let(:top_note_uri) do
    'http://example.com/top-post'
  end

  let(:top_collection_uri) do
    'http://example.com/top-post/replies'
  end

  # The reply uri that has the nested replies under it
  let(:reply_note_uri) do
    'http://other.com/other-reply-2'
  end

  # The collection uri of nested replies
  let(:reply_collection_uri) do
    'http://other.com/other-reply-2/replies'
  end

  let(:replies_top) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: top_collection_uri,
      type: 'Collection',
      items: top_items + top_items_paged,
    }
  end

  let(:replies_nested) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: reply_collection_uri,
      type: 'Collection',
      items: nested_items + nested_items_paged,
    }
  end

  # The status resource for the top post
  let(:top_object) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: top_note_uri,
      type: 'Note',
      content: 'Lorem ipsum',
      replies: replies_top,
      attributedTo: 'https://example.com',
    }
  end

  # The status resource that has the uri to the replies collection
  let(:reply_object) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: reply_note_uri,
      type: 'Note',
      content: 'Lorem ipsum',
      replies: replies_nested,
      attributedTo: 'https://other.com',
    }
  end

  let(:empty_object) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'https://example.com/empty',
      type: 'Note',
      content: 'Lorem ipsum',
      replies: [],
      attributedTo: 'https://example.com',
    }
  end

  let(:account) { Fabricate(:account, domain: 'example.com') }
  let(:status) do
    Fabricate(
      :status,
      account: account,
      uri: top_note_uri,
      created_at: 1.day.ago - Status::FetchRepliesConcern::FETCH_REPLIES_INITIAL_WAIT_MINUTES
    )
  end

  before do
    all_items.each do |item|
      next if [top_note_uri, reply_note_uri].include? item

      stub_request(:get, item).to_return(status: 200, body: Oj.dump(empty_object), headers: { 'Content-Type': 'application/activity+json' })
    end

    stub_request(:get, top_note_uri).to_return(status: 200, body: Oj.dump(top_object), headers: { 'Content-Type': 'application/activity+json' })
    stub_request(:get, reply_note_uri).to_return(status: 200, body: Oj.dump(reply_object), headers: { 'Content-Type': 'application/activity+json' })
  end

  shared_examples 'fetches all replies' do
    it 'fetches statuses recursively' do
      got_uris = subject.perform(status.id)
      expect(got_uris).to match_array(all_items)
    end

    it 'respects the maximum limits set by not recursing after the max is reached' do
      stub_const('ActivityPub::FetchAllRepliesWorker::MAX_REPLIES', 5)
      got_uris = subject.perform(status.id)
      expect(got_uris).to match_array(top_items + top_items_paged)
    end

    it 'fetches the top status only once' do
      _ = subject.perform(status.id, { request_id: 0 })
      expect(FetchReplyWorker).to have_enqueued_sidekiq_job(top_note_uri, { 'prefetched_body' => top_object.deep_stringify_keys, 'request_id' => 0 })
      expect(a_request(:get, top_note_uri)).to have_been_made.once
    end
  end

  describe 'perform' do
    context 'when the payload is a Note with replies as a Collection of inlined replies' do
      it_behaves_like 'fetches all replies'
    end

    context 'when the payload is a Note with replies as a URI to a Collection' do
      let(:top_object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: top_note_uri,
          type: 'Note',
          content: 'Lorem ipsum',
          replies: top_collection_uri,
          attributedTo: 'https://example.com',
        }
      end
      let(:reply_object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: reply_note_uri,
          type: 'Note',
          content: 'Lorem ipsum',
          replies: reply_collection_uri,
          attributedTo: 'https://other.com',
        }
      end

      before do
        stub_request(:get, top_collection_uri).to_return(status: 200, body: Oj.dump(replies_top), headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, reply_collection_uri).to_return(status: 200, body: Oj.dump(replies_nested), headers: { 'Content-Type': 'application/activity+json' })
      end

      it_behaves_like 'fetches all replies'
    end

    context 'when the payload is a Note with replies as a paginated collection' do
      let(:top_page_2_uri) do
        "#{top_collection_uri}/2"
      end

      let(:reply_page_2_uri) do
        "#{reply_collection_uri}/2"
      end

      let(:top_object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: top_note_uri,
          type: 'Note',
          content: 'Lorem ipsum',
          replies: {
            type: 'Collection',
            id: top_collection_uri,
            first: {
              type: 'CollectionPage',
              partOf: top_collection_uri,
              items: top_items,
              next: top_page_2_uri,
            },
          },
          attributedTo: 'https://example.com',
        }
      end
      let(:reply_object) do
        {
          '@context': 'https://www.w3.org/ns/activitystreams',
          id: reply_note_uri,
          type: 'Note',
          content: 'Lorem ipsum',
          replies: {
            type: 'Collection',
            id: reply_collection_uri,
            first: {
              type: 'CollectionPage',
              partOf: reply_collection_uri,
              items: nested_items,
              next: reply_page_2_uri,
            },
          },
          attributedTo: 'https://other.com',
        }
      end

      let(:top_page_two) do
        {
          type: 'CollectionPage',
          id: top_page_2_uri,
          partOf: top_collection_uri,
          items: top_items_paged,
        }
      end

      let(:reply_page_two) do
        {
          type: 'CollectionPage',
          id: reply_page_2_uri,
          partOf: reply_collection_uri,
          items: nested_items_paged,
        }
      end

      before do
        stub_request(:get, top_page_2_uri).to_return(status: 200, body: Oj.dump(top_page_two), headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, reply_page_2_uri).to_return(status: 200, body: Oj.dump(reply_page_two), headers: { 'Content-Type': 'application/activity+json' })
      end

      it_behaves_like 'fetches all replies'

      it 'limits by max pages' do
        stub_const('ActivityPub::FetchAllRepliesWorker::MAX_PAGES', 3)
        got_uris = subject.perform(status.id)
        expect(got_uris).to match_array(top_items + top_items_paged + nested_items)
      end
    end

    context 'when replies should not be fetched' do
      # ensure that we should not fetch by setting the status to be created in the debounce window
      let(:status) { Fabricate(:status, account: account, uri: top_note_uri, created_at: DateTime.now) }

      before do
        stub_const('Status::FetchRepliesConcern::FETCH_REPLIES_INITIAL_WAIT_MINUTES', 1.week)
      end

      it 'returns nil without fetching' do
        got_uris = subject.perform(status.id)
        expect(got_uris).to be_nil
        assert_not_requested :get, top_note_uri
      end
    end
  end
end
