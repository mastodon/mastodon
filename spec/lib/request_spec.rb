# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

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
      before { stub_request(:get, 'http://example.com') }

      it 'executes a HTTP request' do
        expect { |block| subject.perform &block }.to yield_control
        expect(a_request(:get, 'http://example.com')).to have_been_made.once
      end

      it 'executes a HTTP request when the first address is private' do
        resolver = double

        allow(resolver).to receive(:getaddresses).with('example.com').and_return(%w(0.0.0.0 2001:4860:4860::8844))
        allow(resolver).to receive(:timeouts=).and_return(nil)
        allow(Resolv::DNS).to receive(:open).and_yield(resolver)

        expect { |block| subject.perform &block }.to yield_control
        expect(a_request(:get, 'http://example.com')).to have_been_made.once
      end

      it 'sets headers' do
        expect { |block| subject.perform &block }.to yield_control
        expect(a_request(:get, 'http://example.com').with(headers: subject.headers)).to have_been_made
      end

      it 'closes underlaying connection' do
        expect_any_instance_of(HTTP::Client).to receive(:close)
        expect { |block| subject.perform &block }.to yield_control
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
        resolver = double

        allow(resolver).to receive(:getaddresses).with('example.com').and_return(%w(0.0.0.0 2001:db8::face))
        allow(resolver).to receive(:timeouts=).and_return(nil)
        allow(Resolv::DNS).to receive(:open).and_yield(resolver)

        expect { subject.perform }.to raise_error Mastodon::ValidationError
      end
    end
  end

  describe "response's body_with_limit method" do
    it 'rejects body more than 1 megabyte by default' do
      stub_request(:any, 'http://example.com').to_return(body: SecureRandom.random_bytes(2.megabytes))
      expect { subject.perform { |response| response.body_with_limit } }.to raise_error Mastodon::LengthValidationError
    end

    it 'accepts body less than 1 megabyte by default' do
      stub_request(:any, 'http://example.com').to_return(body: SecureRandom.random_bytes(2.kilobytes))
      expect { subject.perform { |response| response.body_with_limit } }.not_to raise_error
    end

    it 'rejects body by given size' do
      stub_request(:any, 'http://example.com').to_return(body: SecureRandom.random_bytes(2.kilobytes))
      expect { subject.perform { |response| response.body_with_limit(1.kilobyte) } }.to raise_error Mastodon::LengthValidationError
    end

    it 'rejects too large chunked body' do
      stub_request(:any, 'http://example.com').to_return(body: SecureRandom.random_bytes(2.megabytes), headers: { 'Transfer-Encoding' => 'chunked' })
      expect { subject.perform { |response| response.body_with_limit } }.to raise_error Mastodon::LengthValidationError
    end

    it 'rejects too large monolithic body' do
      stub_request(:any, 'http://example.com').to_return(body: SecureRandom.random_bytes(2.megabytes), headers: { 'Content-Length' => 2.megabytes })
      expect { subject.perform { |response| response.body_with_limit } }.to raise_error Mastodon::LengthValidationError
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
