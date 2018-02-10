require 'rails_helper'

RSpec.describe FetchAtomService do
  describe '#call' do
    let(:url) { 'http://example.com' }
    subject { FetchAtomService.new.call(url) }

    context 'url is blank' do
      let(:url) { '' }
      it { is_expected.to be_nil }
    end

    context 'request failed' do
      before do
        WebMock.stub_request(:get, url).to_return(status: 500, body: '', headers: {})
      end

      it { is_expected.to be_nil }
    end

    context 'raise OpenSSL::SSL::SSLError' do
      before do
        allow(Request).to receive_message_chain(:new, :add_headers, :perform).and_raise(OpenSSL::SSL::SSLError)
      end

      it 'output log and return nil' do
        expect_any_instance_of(ActiveSupport::Logger).to receive(:debug).with('SSL error: OpenSSL::SSL::SSLError')
        is_expected.to be_nil
      end
    end

    context 'raise HTTP::ConnectionError' do
      before do
        allow(Request).to receive_message_chain(:new, :add_headers, :perform).and_raise(HTTP::ConnectionError)
      end

      it 'output log and return nil' do
        expect_any_instance_of(ActiveSupport::Logger).to receive(:debug).with('HTTP ConnectionError: HTTP::ConnectionError')
        is_expected.to be_nil
      end
    end

    context 'response success' do
      let(:body) { '' }
      let(:headers) { { 'Content-Type' => content_type } }
      let(:json) {
        { id: 1,
          '@context': ActivityPub::TagManager::CONTEXT,
          type: 'Note',
        }.to_json
      }

      before do
        WebMock.stub_request(:get, url).to_return(status: 200, body: body, headers: headers)
      end

      context 'content type is application/atom+xml' do
        let(:content_type) { 'application/atom+xml' }

        it { is_expected.to eq [url, {:prefetched_body=>""}, :ostatus] }
      end

      context 'content_type is json' do
        let(:content_type) { 'application/activity+json' }
        let(:body) { json }

        it { is_expected.to eq [1, { prefetched_body: body, id: true }, :activitypub] }
      end

      before do
        WebMock.stub_request(:get, url).to_return(status: 200, body: body, headers: headers)
        WebMock.stub_request(:get, 'http://example.com/foo').to_return(status: 200, body: json, headers: { 'Content-Type' => 'application/activity+json' })
      end

      context 'has link header' do
        let(:headers) { { 'Link' => '<http://example.com/foo>; rel="alternate"; type="application/activity+json"', } }

        it { is_expected.to eq [1, { prefetched_body: json, id: true }, :activitypub] }
      end

      context 'content type is text/html' do
        let(:content_type) { 'text/html' }
        let(:body) { '<html><head><link rel="alternate" href="http://example.com/foo" type="application/activity+json"/></head></html>' }

        it { is_expected.to eq [1, { prefetched_body: json, id: true }, :activitypub] }
      end
    end
  end
end
