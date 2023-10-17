# frozen_string_literal: true

require 'rails_helper'

describe CacheBuster do
  subject { described_class.new(secret_header: secret_header, secret: secret, http_method: http_method) }

  let(:secret_header) { nil }
  let(:secret) { nil }
  let(:http_method) { nil }

  let(:purge_url) { 'https://example.com/test_purge' }

  describe '#bust' do
    shared_examples 'makes_request' do
      it 'makes an HTTP purging request' do
        method = http_method&.to_sym || :get
        stub_request(method, purge_url).to_return(status: 200)

        subject.bust(purge_url)

        test_request = a_request(method, purge_url)

        test_request = test_request.with(headers: { secret_header => secret }) if secret && secret_header

        expect(test_request).to have_been_made.once
      end
    end

    context 'when using default options' do
      around do |example|
        # Disables the CacheBuster.new deprecation warning about default arguments.
        # Remove this `silence` block when default arg support is removed from CacheBuster
        ActiveSupport::Deprecation.silence do
          example.run
        end
      end

      include_examples 'makes_request'
    end

    context 'when specifying a secret header' do
      let(:secret_header) { 'X-Purge-Secret' }
      let(:secret) { SecureRandom.hex(20) }

      include_examples 'makes_request'
    end

    context 'when specifying a PURGE method' do
      let(:http_method) { 'purge' }

      context 'when not using headers' do
        include_examples 'makes_request'
      end

      context 'when specifying a secret header' do
        let(:secret_header) { 'X-Purge-Secret' }
        let(:secret) { SecureRandom.hex(20) }

        include_examples 'makes_request'
      end
    end
  end
end
