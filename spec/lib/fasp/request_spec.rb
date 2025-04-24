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
    end

    context 'when the response is not signed' do
      before do
        stub_request(method, 'https://reqprov.example.com/fasp/test_path')
          .to_return(status: 200)
      end

      it 'raises an error' do
        expect do
          subject.send(method, '/test_path')
        end.to raise_error(Mastodon::SignatureVerificationError)
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
