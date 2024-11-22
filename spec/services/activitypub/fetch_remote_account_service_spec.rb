# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FetchRemoteAccountService do
  subject { described_class.new }

  let!(:actor) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'https://example.com/alice',
      type: 'Person',
      preferredUsername: 'alice',
      name: 'Alice',
      summary: 'Foo bar',
      inbox: 'http://example.com/alice/inbox',
    }
  end

  describe '#call' do
    let(:account) { subject.call('https://example.com/alice') }

    shared_examples 'sets profile data' do
      it 'returns an account with expected details' do
        expect(account)
          .to be_an(Account)
          .and have_attributes(
            display_name: eq('Alice'),
            note: eq('Foo bar'),
            url: eq('https://example.com/alice')
          )
      end
    end

    context 'when the account does not have a inbox' do
      let!(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/alice', type: 'application/activity+json' }] } }

      before do
        actor[:inbox] = nil

        stub_request(:get, 'https://example.com/alice').to_return(body: Oj.dump(actor), headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })
      end

      it 'fetches resource and looks up webfinger and returns nil' do
        expect(account).to be_nil

        expect(a_request(:get, 'https://example.com/alice')).to have_been_made.once
        expect(a_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com')).to have_been_made.once
      end
    end

    context 'when URI and WebFinger share the same host' do
      let!(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/alice', type: 'application/activity+json' }] } }

      before do
        stub_request(:get, 'https://example.com/alice').to_return(body: Oj.dump(actor), headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })
      end

      it 'fetches resource and looks up webfinger and sets attributes' do
        account

        expect(a_request(:get, 'https://example.com/alice')).to have_been_made.once
        expect(a_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com')).to have_been_made.once

        expect(account.username).to eq 'alice'
        expect(account.domain).to eq 'example.com'
      end

      include_examples 'sets profile data'
    end

    context 'when WebFinger presents different domain than URI' do
      let!(:webfinger) { { subject: 'acct:alice@iscool.af', links: [{ rel: 'self', href: 'https://example.com/alice', type: 'application/activity+json' }] } }

      before do
        stub_request(:get, 'https://example.com/alice').to_return(body: Oj.dump(actor), headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })
        stub_request(:get, 'https://iscool.af/.well-known/webfinger?resource=acct:alice@iscool.af').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })
      end

      it 'fetches resource and looks up webfinger and follows redirection and sets attributes' do
        account

        expect(a_request(:get, 'https://example.com/alice')).to have_been_made.once
        expect(a_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com')).to have_been_made.once
        expect(a_request(:get, 'https://iscool.af/.well-known/webfinger?resource=acct:alice@iscool.af')).to have_been_made.once

        expect(account.username).to eq 'alice'
        expect(account.domain).to eq 'iscool.af'
      end

      include_examples 'sets profile data'
    end

    context 'when WebFinger returns a different URI' do
      let!(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/bob', type: 'application/activity+json' }] } }

      before do
        stub_request(:get, 'https://example.com/alice').to_return(body: Oj.dump(actor), headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })
      end

      it 'fetches resource and looks up webfinger and does not create account' do
        expect(account).to be_nil

        expect(a_request(:get, 'https://example.com/alice')).to have_been_made.once
        expect(a_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com')).to have_been_made.once
      end
    end

    context 'when WebFinger returns a different URI after a redirection' do
      let!(:webfinger) { { subject: 'acct:alice@iscool.af', links: [{ rel: 'self', href: 'https://example.com/bob', type: 'application/activity+json' }] } }

      before do
        stub_request(:get, 'https://example.com/alice').to_return(body: Oj.dump(actor), headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })
        stub_request(:get, 'https://iscool.af/.well-known/webfinger?resource=acct:alice@iscool.af').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })
      end

      it 'fetches resource and looks up webfinger and follows redirect and does not create account' do
        expect(account).to be_nil

        expect(a_request(:get, 'https://example.com/alice')).to have_been_made.once
        expect(a_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com')).to have_been_made.once
        expect(a_request(:get, 'https://iscool.af/.well-known/webfinger?resource=acct:alice@iscool.af')).to have_been_made.once
      end
    end

    context 'with wrong id' do
      it 'does not create account' do
        expect(subject.call('https://fake.address/@foo', prefetched_body: Oj.dump(actor))).to be_nil
      end
    end
  end
end
