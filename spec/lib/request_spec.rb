# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

describe Request do
  subject { described_class.new(:get, url) }

  let(:url) { 'http://example.com' }

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
      before { stub_request(:get, 'http://example.com') }

      it 'executes a HTTP request' do
        expect { |block| subject.perform(&block) }.to yield_control
        expect(a_request(:get, 'http://example.com')).to have_been_made.once
      end

      it 'executes a HTTP request when the first address is private' do
        resolver = instance_double(Resolv::DNS)

        allow(resolver).to receive(:getaddresses).with('example.com').and_return(%w(0.0.0.0 2001:4860:4860::8844))
        allow(resolver).to receive(:timeouts=).and_return(nil)
        allow(Resolv::DNS).to receive(:open).and_yield(resolver)

        expect { |block| subject.perform(&block) }.to yield_control
        expect(a_request(:get, 'http://example.com')).to have_been_made.once
      end

      it 'sets headers' do
        expect { |block| subject.perform(&block) }.to yield_control
        expect(a_request(:get, 'http://example.com').with(headers: subject.headers)).to have_been_made
      end

      it 'closes underlying connection' do
        expect_any_instance_of(HTTP::Client).to receive(:close)
        expect { |block| subject.perform(&block) }.to yield_control
      end

      it 'returns response which implements body_with_limit' do
        subject.perform do |response|
          expect(response).to respond_to :body_with_limit
        end
      end
    end

    context 'with private host' do
      around do |example|
        WebMock.disable!
        example.run
        WebMock.enable!
      end

      it 'raises Mastodon::ValidationError' do
        resolver = instance_double(Resolv::DNS)

        allow(resolver).to receive(:getaddresses).with('example.com').and_return(%w(0.0.0.0 2001:db8::face))
        allow(resolver).to receive(:timeouts=).and_return(nil)
        allow(Resolv::DNS).to receive(:open).and_yield(resolver)

        expect { subject.perform }.to raise_error Mastodon::ValidationError
      end
    end

    context 'with bare domain URL' do
      let(:url) { 'http://example.com' }

      before do
        stub_request(:get, 'http://example.com')
      end

      it 'normalizes path' do
        subject.perform do |response|
          expect(response.request.uri.path).to eq '/'
        end
      end

      it 'normalizes path used for request signing' do
        subject.perform

        headers = subject.instance_variable_get(:@headers)
        expect(headers[Request::REQUEST_TARGET]).to eq 'get /'
      end

      it 'normalizes path used in request line' do
        subject.perform do |response|
          expect(response.request.headline).to eq 'GET / HTTP/1.1'
        end
      end
    end

    context 'with unnormalized URL' do
      let(:url) { 'HTTP://EXAMPLE.com:80/foo%41%3A?bar=%41%3A#baz' }

      before do
        stub_request(:get, 'http://example.com/foo%41%3A?bar=%41%3A')
      end

      it 'normalizes scheme' do
        subject.perform do |response|
          expect(response.request.uri.scheme).to eq 'http'
        end
      end

      it 'normalizes host' do
        subject.perform do |response|
          expect(response.request.uri.authority).to eq 'example.com'
        end
      end

      it 'does not modify path' do
        subject.perform do |response|
          expect(response.request.uri.path).to eq '/foo%41%3A'
        end
      end

      it 'does not modify query string' do
        subject.perform do |response|
          expect(response.request.uri.query).to eq 'bar=%41%3A'
        end
      end

      it 'does not modify path used for request signing' do
        subject.perform

        headers = subject.instance_variable_get(:@headers)
        expect(headers[Request::REQUEST_TARGET]).to eq 'get /foo%41%3A'
      end

      it 'does not modify path used in request line' do
        subject.perform do |response|
          expect(response.request.headline).to eq 'GET /foo%41%3A?bar=%41%3A HTTP/1.1'
        end
      end

      it 'strips fragment' do
        subject.perform do |response|
          expect(response.request.uri.fragment).to be_nil
        end
      end
    end

    context 'with non-ASCII URL' do
      let(:url) { 'http://éxample.com:81/föo?bär=1' }

      before do
        stub_request(:get, 'http://xn--xample-9ua.com:81/f%C3%B6o?b%C3%A4r=1')
      end

      it 'IDN-encodes host' do
        subject.perform do |response|
          expect(response.request.uri.authority).to eq 'xn--xample-9ua.com:81'
        end
      end

      it 'IDN-encodes host in Host header' do
        subject.perform do |response|
          expect(response.request.headers['Host']).to eq 'xn--xample-9ua.com'
        end
      end

      it 'percent-escapes path used for request signing' do
        subject.perform

        headers = subject.instance_variable_get(:@headers)
        expect(headers[Request::REQUEST_TARGET]).to eq 'get /f%C3%B6o'
      end

      it 'normalizes path used in request line' do
        subject.perform do |response|
          expect(response.request.headline).to eq 'GET /f%C3%B6o?b%C3%A4r=1 HTTP/1.1'
        end
      end
    end

    context 'with redirecting URL' do
      let(:url) { 'http://example.com/foo' }

      before do
        stub_request(:get, 'http://example.com/foo').to_return(status: 302, headers: { 'Location' => 'HTTPS://EXAMPLE.net/Bar' })
        stub_request(:get, 'https://example.net/Bar').to_return(body: 'Lorem ipsum')
      end

      it 'resolves redirect' do
        subject.perform do |response|
          expect(response.body.to_s).to eq 'Lorem ipsum'
        end

        expect(a_request(:get, 'https://example.net/Bar')).to have_been_made
      end

      it 'normalizes destination scheme' do
        subject.perform do |response|
          expect(response.request.uri.scheme).to eq 'https'
        end
      end

      it 'normalizes destination host' do
        subject.perform do |response|
          expect(response.request.uri.authority).to eq 'example.net'
        end
      end

      it 'does modify path' do
        subject.perform do |response|
          expect(response.request.uri.path).to eq '/Bar'
        end
      end
    end
  end

  describe "response's body_with_limit method" do
    it 'rejects body more than 1 megabyte by default' do
      stub_request(:any, 'http://example.com').to_return(body: SecureRandom.random_bytes(2.megabytes))
      expect { subject.perform(&:body_with_limit) }.to raise_error Mastodon::LengthValidationError
    end

    it 'accepts body less than 1 megabyte by default' do
      stub_request(:any, 'http://example.com').to_return(body: SecureRandom.random_bytes(2.kilobytes))
      expect { subject.perform(&:body_with_limit) }.to_not raise_error
    end

    it 'rejects body by given size' do
      stub_request(:any, 'http://example.com').to_return(body: SecureRandom.random_bytes(2.kilobytes))
      expect { subject.perform { |response| response.body_with_limit(1.kilobyte) } }.to raise_error Mastodon::LengthValidationError
    end

    it 'rejects too large chunked body' do
      stub_request(:any, 'http://example.com').to_return(body: SecureRandom.random_bytes(2.megabytes), headers: { 'Transfer-Encoding' => 'chunked' })
      expect { subject.perform(&:body_with_limit) }.to raise_error Mastodon::LengthValidationError
    end

    it 'rejects too large monolithic body' do
      stub_request(:any, 'http://example.com').to_return(body: SecureRandom.random_bytes(2.megabytes), headers: { 'Content-Length' => 2.megabytes })
      expect { subject.perform(&:body_with_limit) }.to raise_error Mastodon::LengthValidationError
    end

    it 'truncates large monolithic body' do
      stub_request(:any, 'http://example.com').to_return(body: SecureRandom.random_bytes(2.megabytes), headers: { 'Content-Length' => 2.megabytes })
      expect(subject.perform { |response| response.truncated_body.bytesize }).to be < 2.megabytes
    end

    it 'uses binary encoding if Content-Type does not tell encoding' do
      stub_request(:any, 'http://example.com').to_return(body: '', headers: { 'Content-Type' => 'text/html' })
      expect(subject.perform { |response| response.body_with_limit.encoding }).to eq Encoding::BINARY
    end

    it 'uses binary encoding if Content-Type tells unknown encoding' do
      stub_request(:any, 'http://example.com').to_return(body: '', headers: { 'Content-Type' => 'text/html; charset=unknown' })
      expect(subject.perform { |response| response.body_with_limit.encoding }).to eq Encoding::BINARY
    end

    it 'uses encoding specified by Content-Type' do
      stub_request(:any, 'http://example.com').to_return(body: '', headers: { 'Content-Type' => 'text/html; charset=UTF-8' })
      expect(subject.perform { |response| response.body_with_limit.encoding }).to eq Encoding::UTF_8
    end
  end
end
