# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

RSpec.describe Fasp::Request do
  include ProviderRequestHelper

  subject { described_class.new(provider) }

  let(:provider) do
    Fabricate(:fasp_provider, base_url: 'https://reqprov.example.com/fasp')
  end

  shared_examples 'a provider request' do |method|
    context 'when the response is signed by the provider' do
      before do
        stub_provider_request(provider, method:, path: '/test_path')
      end

      it "performs a signed #{method.to_s.upcase} request relative to the base_path of the fasp" do
        subject.send(method, '/test_path')

        expect(WebMock).to have_requested(method, 'https://reqprov.example.com/fasp/test_path')
          .with(headers: {
            'Signature' => /.+/,
            'Signature-Input' => /.+/,
          })
      end

      it 'tracks that a successful connection was made' do
        provider.delivery_failure_tracker.track_failure!

        expect do
          subject.send(method, '/test_path')
        end.to change(provider.delivery_failure_tracker, :failures).from(1).to(0)
      end
    end

    context 'when the response is not signed' do
      before do
        stub_request(method, 'https://reqprov.example.com/fasp/test_path')
          .to_return(status:)
      end

      context 'when the request was successful' do
        let(:status) { 200 }

        it 'raises a signature verification error' do
          expect do
            subject.send(method, '/test_path')
          end.to raise_error(Mastodon::SignatureVerificationError)
        end
      end

      context 'when an error response is received' do
        let(:status) { 401 }

        it 'raises an unexpected response error' do
          expect do
            subject.send(method, '/test_path')
          end.to raise_error(Mastodon::UnexpectedResponseError)
        end
      end
    end

    context 'when the request raises an error' do
      before do
        stub_request(method, 'https://reqprov.example.com/fasp/test_path')
          .to_raise(HTTP::ConnectionError)
      end

      it "records the failure using the provider's delivery failure tracker" do
        expect do
          subject.send(method, '/test_path')
        end.to raise_error(HTTP::ConnectionError)

        expect(provider.delivery_failure_tracker.failures).to eq 1
      end
    end

    context 'when the provider host name resolves to a private address' do
      around do |example|
        WebMock.disable!
        example.run
        WebMock.enable!
      end

      it 'raises Mastodon::ValidationError' do
        resolver = instance_double(Resolv::DNS)

        allow(resolver).to receive(:getaddresses).with('reqprov.example.com').and_return(%w(0.0.0.0 2001:db8::face))
        allow(resolver).to receive(:timeouts=).and_return(nil)
        allow(Resolv::DNS).to receive(:open).and_yield(resolver)

        expect { subject.send(method, '/test_path') }.to raise_error(Mastodon::ValidationError)
      end
    end
  end

  describe '#get' do
    it_behaves_like 'a provider request', :get
  end

  describe '#post' do
    it_behaves_like 'a provider request', :post
  end

  describe '#delete' do
    it_behaves_like 'a provider request', :delete
  end
end
