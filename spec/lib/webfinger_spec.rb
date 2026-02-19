# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webfinger do
  describe 'self link' do
    subject { described_class.new('acct:alice@example.com').perform }

    context 'when self link is specified with type application/activity+json' do
      let!(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/alice', type: 'application/activity+json' }] } }

      it 'correctly parses the response' do
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })

        expect(subject.self_link_href).to eq 'https://example.com/alice'
      end
    end

    context 'when self link is specified with type application/ld+json' do
      let!(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/alice', type: 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"' }] } }

      it 'correctly parses the response' do
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })

        expect(subject.self_link_href).to eq 'https://example.com/alice'
      end
    end

    context 'when self link is specified with incorrect type' do
      let!(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/alice', type: 'application/json"' }] } }

      it 'raises an error' do
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })

        expect { subject }
          .to raise_error(Webfinger::Error)
      end
    end

    context 'when webfinger fails and host meta is used' do
      before { stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(status: 404) }

      context 'when host meta succeeds' do
        let(:host_meta) do
          <<~XML
            <?xml version="1.0"?>
            <XRD xmlns="http://docs.oasis-open.org/ns/xri/xrd-1.0">
              <Link rel="lrdd" type="application/xrd+xml" template="https://example.com/.well-known/nonStandardWebfinger?resource={uri}"/>
            </XRD>
          XML
        end
        let(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/alice-from-NS', type: 'application/activity+json' }] } }

        before do
          stub_request(:get, 'https://example.com/.well-known/host-meta').to_return(body: host_meta, headers: { 'Content-Type': 'application/jrd+json' })
          stub_request(:get, 'https://example.com/.well-known/nonStandardWebfinger?resource=acct:alice@example.com').to_return(body: Oj.dump(webfinger), headers: { 'Content-Type': 'application/jrd+json' })
        end

        it 'uses host meta details' do
          expect(subject.self_link_href)
            .to eq 'https://example.com/alice-from-NS'
        end
      end

      context 'when host meta fails' do
        before do
          stub_request(:get, 'https://example.com/.well-known/host-meta').to_return(status: 500)
        end

        it 'raises error' do
          expect { subject }
            .to raise_error(Webfinger::Error)
        end
      end
    end
  end
end
