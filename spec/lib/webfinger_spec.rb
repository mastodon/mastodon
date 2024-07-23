# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webfinger do
  describe 'self link' do
    context 'when self link is specified with type application/activity+json' do
      let!(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/alice', type: 'application/activity+json' }] } }

      it 'correctly parses the response' do
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })

        response = described_class.new('acct:alice@example.com').perform

        expect(response.self_link_href).to eq 'https://example.com/alice'
      end
    end

    context 'when self link is specified with type application/ld+json' do
      let!(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/alice', type: 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"' }] } }

      it 'correctly parses the response' do
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })

        response = described_class.new('acct:alice@example.com').perform

        expect(response.self_link_href).to eq 'https://example.com/alice'
      end
    end

    context 'when self link is specified with incorrect type' do
      let!(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/alice', type: 'application/json"' }] } }

      it 'raises an error' do
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })

        expect { described_class.new('acct:alice@example.com').perform }.to raise_error(Webfinger::Error)
      end
    end
  end
end
