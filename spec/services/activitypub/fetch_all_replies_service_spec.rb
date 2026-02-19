# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FetchAllRepliesService do
  subject { described_class.new }

  let(:actor)          { Fabricate(:account, domain: 'example.com', uri: 'http://example.com/account') }
  let(:status)         { Fabricate(:status, account: actor) }
  let(:collection_uri) { 'http://example.com/replies/1' }

  let(:items) do
    %w(
      http://example.com/self-reply-1
      http://example.com/self-reply-2
      http://example.com/self-reply-3
      http://other.com/other-reply-1
      http://other.com/other-reply-2
      http://other.com/other-reply-3
      http://example.com/self-reply-4
      http://example.com/self-reply-5
      http://example.com/self-reply-6
    )
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
    it 'fetches more than the default maximum and from multiple domains' do
      allow(FetchReplyWorker).to receive(:push_bulk)

      subject.call(status.uri, payload)

      expect(FetchReplyWorker).to have_received(:push_bulk).with(
        %w(
          http://example.com/self-reply-1
          http://example.com/self-reply-2
          http://example.com/self-reply-3
          http://other.com/other-reply-1
          http://other.com/other-reply-2
          http://other.com/other-reply-3
          http://example.com/self-reply-4
          http://example.com/self-reply-5
          http://example.com/self-reply-6
        )
      )
    end

    context 'with a recent status' do
      before do
        Fabricate(:status, uri: 'http://example.com/self-reply-2', fetched_replies_at: 1.second.ago, local: false)
      end

      it 'skips statuses that have been updated recently' do
        allow(FetchReplyWorker).to receive(:push_bulk)

        subject.call(status.uri, payload)

        expect(FetchReplyWorker).to have_received(:push_bulk).with(
          %w(
            http://example.com/self-reply-1
            http://example.com/self-reply-3
            http://other.com/other-reply-1
            http://other.com/other-reply-2
            http://other.com/other-reply-3
            http://example.com/self-reply-4
            http://example.com/self-reply-5
            http://example.com/self-reply-6
          )
        )
      end
    end

    context 'with an old status' do
      before do
        Fabricate(:status, uri: 'http://other.com/other-reply-1', fetched_replies_at: 1.year.ago, created_at: 1.year.ago, account: actor)
      end

      it 'updates the time that fetched statuses were last fetched' do
        allow(FetchReplyWorker).to receive(:push_bulk)

        subject.call(status.uri, payload)

        expect(Status.find_by(uri: 'http://other.com/other-reply-1').fetched_replies_at).to be >= 1.minute.ago
      end
    end

    context 'with unsubscribed replies' do
      before do
        remote_actor = Fabricate(:account, domain: 'other.com', uri: 'http://other.com/account')
        # reply not in the collection from the remote instance, but we know about anyway without anyone following the account
        Fabricate(:status, account: remote_actor, in_reply_to_id: status.id, uri: 'http://other.com/account/unsubscribed', fetched_replies_at: 1.year.ago, created_at: 1.year.ago)
      end

      it 'updates the unsubscribed replies' do
        allow(FetchReplyWorker).to receive(:push_bulk)

        subject.call(status.uri, payload)

        expect(FetchReplyWorker).to have_received(:push_bulk).with(
          %w(
            http://example.com/self-reply-1
            http://example.com/self-reply-2
            http://example.com/self-reply-3
            http://other.com/other-reply-1
            http://other.com/other-reply-2
            http://other.com/other-reply-3
            http://example.com/self-reply-4
            http://example.com/self-reply-5
            http://example.com/self-reply-6
            http://other.com/account/unsubscribed
          )
        )
      end
    end
  end
end
