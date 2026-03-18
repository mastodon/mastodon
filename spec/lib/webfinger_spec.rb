# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webfinger do
  describe '#initialize' do
    subject { described_class.new(uri) }

    context 'when called with local account' do
      let(:uri) { 'acct:alice' }

      it 'handles value and raises error' do
        expect { subject }.to raise_error(ArgumentError, /for local account/)
      end
    end

    context 'when called with remote account' do
      let(:uri) { 'acct:alice@host.example' }

      it 'handles value and sets attributes' do
        expect { subject }.to_not raise_error
      end
    end
  end

  describe '#perform' do
    subject { described_class.new('acct:alice@example.com').perform }

    context 'when self link is specified with type application/activity+json' do
      let(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/alice', type: 'application/activity+json' }] } }

      before do
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: webfinger.to_json, headers: { 'Content-Type': 'application/jrd+json' })
      end

      it 'correctly parses the response' do
        expect(subject.self_link_href).to eq 'https://example.com/alice'
      end
    end

    context 'when self link is specified with type application/ld+json' do
      let(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/alice', type: 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"' }] } }

      before do
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: webfinger.to_json, headers: { 'Content-Type': 'application/jrd+json' })
      end

      it 'correctly parses the response' do
        expect(subject.self_link_href).to eq 'https://example.com/alice'
      end
    end

    context 'when self link is specified with incorrect type' do
      let(:webfinger) { { subject: 'acct:alice@example.com', links: [{ rel: 'self', href: 'https://example.com/alice', type: 'application/json"' }] } }

      before do
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: webfinger.to_json, headers: { 'Content-Type': 'application/jrd+json' })
      end

      it 'raises an error' do
        expect { subject }
          .to raise_error(Webfinger::Error)
      end
    end

    context 'when response body is not parsable' do
      before do
        stub_request(:get, 'https://example.com/.well-known/webfinger?resource=acct:alice@example.com').to_return(body: 'XXX', headers: { 'Content-Type': 'application/jrd+json' })
      end

      it 'raises an error' do
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
          stub_request(:get, 'https://example.com/.well-known/nonStandardWebfinger?resource=acct:alice@example.com').to_return(body: webfinger.to_json, headers: { 'Content-Type': 'application/jrd+json' })
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
