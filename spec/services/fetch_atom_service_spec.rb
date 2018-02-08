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
      target.instance_variable_set('@response', 'Link' => '<http://example.com/foo>; rel="self", <http://example.com/>; rel = "up"')

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
end
