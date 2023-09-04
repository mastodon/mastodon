# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FetchResourceService, type: :service do
  describe '#call' do
    subject { described_class.new.call(url) }

    let(:url) { 'http://example.com' }

    context 'with blank url' do
      let(:url) { '' }

      it { is_expected.to be_nil }
    end

    context 'when request fails' do
      before do
        stub_request(:get, url).to_return(status: 500, body: '', headers: {})
      end

      it { is_expected.to be_nil }
    end

    context 'when OpenSSL::SSL::SSLError is raised' do
      before do
        request = instance_double(Request)
        allow(Request).to receive(:new).and_return(request)
        allow(request).to receive(:add_headers)
        allow(request).to receive(:on_behalf_of)
        allow(request).to receive(:perform).and_raise(OpenSSL::SSL::SSLError)
      end

      it { is_expected.to be_nil }
    end

    context 'when HTTP::ConnectionError is raised' do
      before do
        request = instance_double(Request)
        allow(Request).to receive(:new).and_return(request)
        allow(request).to receive(:add_headers)
        allow(request).to receive(:on_behalf_of)
        allow(request).to receive(:perform).and_raise(HTTP::ConnectionError)
      end

      it { is_expected.to be_nil }
    end

    context 'when request succeeds' do
      let(:body) { '' }

      let(:content_type) { 'application/json' }

      let(:headers) do
        { 'Content-Type' => content_type }
      end

      let(:json) do
        {
          id: 1,
          '@context': ActivityPub::TagManager::CONTEXT,
          type: 'Note',
        }.to_json
      end

      before do
        stub_request(:get, url).to_return(status: 200, body: body, headers: headers)
        stub_request(:get, 'http://example.com/foo').to_return(status: 200, body: json, headers: { 'Content-Type' => 'application/activity+json' })
      end

      it 'signs request' do
        subject
        expect(a_request(:get, url).with(headers: { 'Signature' => /keyId="#{Regexp.escape(ActivityPub::TagManager.instance.key_uri_for(Account.representative))}"/ })).to have_been_made
      end

      context 'when content type is application/atom+xml' do
        let(:content_type) { 'application/atom+xml' }

        it { is_expected.to be_nil }
      end

      context 'when content type is activity+json' do
        let(:content_type) { 'application/activity+json; charset=utf-8' }
        let(:body) { json }

        it { is_expected.to eq [1, { prefetched_body: body, id: true }] }
      end

      context 'when content type is ld+json with profile' do
        let(:content_type) { 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"' }
        let(:body) { json }

        it { is_expected.to eq [1, { prefetched_body: body, id: true }] }
      end

      context 'when link header is present' do
        let(:headers) { { 'Link' => '<http://example.com/foo>; rel="alternate"; type="application/activity+json"' } }

        it { is_expected.to eq [1, { prefetched_body: json, id: true }] }
      end

      context 'when content type is text/html' do
        let(:content_type) { 'text/html' }
        let(:body) { '<html><head><link rel="alternate" href="http://example.com/foo" type="application/activity+json"/></head></html>' }

        it { is_expected.to eq [1, { prefetched_body: json, id: true }] }
      end
    end
  end
end
