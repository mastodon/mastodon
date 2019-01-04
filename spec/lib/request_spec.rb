# frozen_string_literal: true

require 'rails_helper'

describe Request do
  subject { Request.new(:get, 'http://example.com') }

  describe '#headers' do
    it 'returns user agent' do
      expect(subject.headers['User-Agent']).to be_present
    end

    it 'returns the date header' do
      expect(subject.headers['Date']).to be_present
    end

    it 'returns the host header' do
      expect(subject.headers['Host']).to be_present
    end

    it 'does not return virtual request-target header' do
      expect(subject.headers['(request-target)']).to be_nil
    end
  end

  describe '#on_behalf_of' do
    it 'when used, adds signature header' do
      subject.on_behalf_of(Fabricate(:account))
      expect(subject.headers['Signature']).to be_present
    end
  end

  describe '#add_headers' do
    it 'adds headers to the request' do
      subject.add_headers('Test' => 'Foo')
      expect(subject.headers['Test']).to eq 'Foo'
    end
  end

  describe '#perform' do
    context 'with valid host' do
      before do
        stub_request(:get, 'http://example.com')
        subject.perform
      end

      it 'executes a HTTP request' do
        expect(a_request(:get, 'http://example.com')).to have_been_made.once
      end

      it 'executes a HTTP request when the first address is private' do
        allow(Addrinfo).to receive(:foreach).with('example.com', nil, nil, :SOCK_STREAM)
                                            .and_yield(Addrinfo.new(["AF_INET", 0, "example.com", "0.0.0.0"], :PF_INET, :SOCK_STREAM))
                                            .and_yield(Addrinfo.new(["AF_INET6", 0, "example.com", "2001:4860:4860::8844"], :PF_INET6, :SOCK_STREAM))
        expect(a_request(:get, 'http://example.com')).to have_been_made.once
      end

      it 'sets headers' do
        expect(a_request(:get, 'http://example.com').with(headers: subject.headers)).to have_been_made
      end
    end

    context 'with private host' do
      around do |example|
        WebMock.disable!
        example.run
        WebMock.enable!
      end

      it 'raises Mastodon::ValidationError' do
        allow(Addrinfo).to receive(:foreach).with('example.com', nil, nil, :SOCK_STREAM)
                                            .and_yield(Addrinfo.new(["AF_INET", 0, "example.com", "0.0.0.0"], :PF_INET, :SOCK_STREAM))
                                            .and_yield(Addrinfo.new(["AF_INET6", 0, "example.com", "2001:db8::face"], :PF_INET6, :SOCK_STREAM))
        expect{ subject.perform }.to raise_error Mastodon::ValidationError
      end
    end
  end
end
