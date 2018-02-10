require 'rails_helper'

RSpec.describe FetchAtomService do
  describe '#link_header' do
    context 'Link is Array' do
      target = FetchAtomService.new
      target.instance_variable_set('@response', 'Link' => [
        '<http://example.com/>; rel="up"; meta="bar"',
        '<http://example.com/foo>; rel="self"',
      ])

      it 'set first link as link_header' do
        expect(target.send(:link_header).links[0].href).to eq 'http://example.com/'
      end
    end

    context 'Link is not Array' do
      target = FetchAtomService.new
      target.instance_variable_set('@response', 'Link' => '<http://example.com/foo>; rel="alternate"')

      it { expect(target.send(:link_header).links[0].href).to eq 'http://example.com/foo' }
    end
  end

  describe '#perform_request' do
    let(:url) { 'http://example.com' }
    context 'Check method result' do
      before do
        WebMock.stub_request(:get, url).to_return(status: 200, body: '', headers: {})
        @target = FetchAtomService.new
        @target.instance_variable_set('@url', url)
      end

      it 'HTTP::Response instance is returned and set to @response' do
        expect(@target.send(:perform_request).status.to_s).to eq '200 OK'
        expect(@target.instance_variable_get('@response')).to be_instance_of HTTP::Response
      end
    end

    context 'check passed parameters to Request' do
      before do
        @target = FetchAtomService.new
        @target.instance_variable_set('@url', url)
        @target.instance_variable_set('@unsupported_activity', unsupported_activity)
        allow(Request).to receive(:new).with(:get, url)
        expect(Request).to receive_message_chain(:new, :add_headers).with('Accept' => accept)
        allow(Request).to receive_message_chain(:new, :add_headers, :perform).with(no_args)
      end

      context '@unsupported_activity is true' do
        let(:unsupported_activity) { true }
        let(:accept) { 'text/html' }
        it { @target.send(:perform_request) }
      end

      context '@unsupported_activity is false' do
        let(:unsupported_activity) { false }
        let(:accept) { 'application/activity+json, application/ld+json, application/atom+xml, text/html' }
        it { @target.send(:perform_request) }
      end
    end
  end

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
