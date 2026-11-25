# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::FetchRelayService do
  let(:webfinger) do
    {
      subject: 'acct:hoge@example.com',
      links: [
        {
          rel: 'self',
          href: 'https://example.com/actor',
          type: 'application/activity+json',
        },
      ],
    }
  end

  let(:actor) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'https://example.com/actor',
      type: 'Service',
      preferredUsername: 'hoge',
      name: 'Relay',
      summary: 'Foo bar',
      inbox: 'https://example.com/inbox',
    }
  end

  describe '#call' do
    subject { described_class.new.call(relay) }

    let(:acct) { 'hoge@example.com' }
    let(:relay) { Relay.new(acct:) }

    context 'when the actor document returns a temporary error' do
      before do
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:hoge@example.com').to_return(status: 500)
      end

      it 'raises error' do
        expect { subject }.to raise_error ActivityPub::FetchRelayService::Error
      end
    end

    context 'when the actor document returns a 410 not found error' do
      before do
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:hoge@example.com').to_return(status: 410)
      end

      it 'raises error' do
        expect { subject }.to raise_error ActivityPub::FetchRelayService::Error
      end
    end

    context 'when the actor document returns invalid JSON' do
      before do
        stub_request(:get, 'https://example.com/actor').to_return(body: '{{22', headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:hoge@example.com').to_return(body: webfinger.to_json, headers: { 'Content-Type': 'application/jrd+json' })
      end

      it 'raises error' do
        expect { subject }.to raise_error ActivityPub::FetchRelayService::Error
      end
    end

    context 'when the response is valid' do
      before do
        stub_request(:get, 'https://example.com/actor').to_return(body: actor.to_json, headers: { 'Content-Type': 'application/activity+json' })
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:hoge@example.com').to_return(body: webfinger.to_json, headers: { 'Content-Type': 'application/jrd+json' })
      end

      it 'fetches resource and looks up webfinger and sets values' do
        subject

        expect(a_request(:get, 'https://example.com/actor')).to have_been_made.once
        expect(a_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:hoge@example.com')).to have_been_made.twice

        expect(relay.display_name).to eq 'Relay'
        expect(relay.note).to eq 'Foo bar'
        expect(relay.uri).to eq 'https://example.com/actor'
        expect(relay.inbox_url).to eq 'https://example.com/inbox'
      end
    end
  end
end
