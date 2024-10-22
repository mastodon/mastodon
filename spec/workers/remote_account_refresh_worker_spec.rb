# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RemoteAccountRefreshWorker do
  let(:account) { Fabricate(:account, username: 'alice', domain: 'other.com') }
  let(:account_object) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: account.uri,
      type: 'Person',
      preferredUsername: 'alice',
      name: 'Alice',
      summary: 'Foo bar',
      inbox: 'http://example.com/alice/inbox',
    }.with_indifferent_access
  end
  let!(:webfinger) { { subject: 'acct:alice@other.com', links: [{ rel: 'self', href: 'https://other.com/alice', type: 'application/activity+json' }] } }

  describe '#perform' do
    before do
      stub_request(:get, account.uri).to_return(status: 200, body: Oj.dump(account_object), headers: { 'Content-Type': 'application/activity+json' })
      stub_request(:get, 'https://other.com/.well-known/webfinger?resource=acct:alice@other.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })
    end

    it 'triggers fetching the remote account' do
      account_backfill_service = instance_double(ActivityPub::AccountBackfillService, call: true)
      fetch_remote_account_service = instance_double(ActivityPub::FetchRemoteAccountService, call: true)
      allow(ActivityPub::AccountBackfillService).to receive(:new).and_return(account_backfill_service)
      allow(ActivityPub::FetchRemoteAccountService).to receive(:new).and_return(fetch_remote_account_service, call: true)
      subject.perform(account.id)
      expect(fetch_remote_account_service).to have_received(:call).with(account.uri, { prefetched_body: account_object })
    end

    it 'triggers an account backfill' do
      account_backfill_service = instance_double(ActivityPub::AccountBackfillService, call: true)
      fetch_remote_account_service = instance_double(ActivityPub::FetchRemoteAccountService, call: true)
      allow(ActivityPub::AccountBackfillService).to receive(:new).and_return(account_backfill_service)
      allow(ActivityPub::FetchRemoteAccountService).to receive(:new).and_return(fetch_remote_account_service, call: true)
      subject.perform(account.id)
      expect(account_backfill_service).to have_received(:call).with(account, { prefetched_body: account_object })
    end
  end
end
