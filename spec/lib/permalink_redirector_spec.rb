# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PermalinkRedirector do
  let(:remote_account) { Fabricate(:account, username: 'alice', domain: 'example.com', url: 'https://example.com/@alice', id: 2) }

  describe '#redirect_url' do
    before do
      Fabricate(:status, account: remote_account, id: 123, url: 'https://example.com/status-123')
    end

    it 'returns path for legacy account links' do
      redirector = described_class.new('accounts/2')
      expect(redirector.redirect_path).to eq 'https://example.com/@alice'
    end

    it 'returns path for legacy status links' do
      redirector = described_class.new('statuses/123')
      expect(redirector.redirect_path).to eq 'https://example.com/status-123'
    end

    it 'returns path for pretty account links' do
      redirector = described_class.new('@alice@example.com')
      expect(redirector.redirect_path).to eq 'https://example.com/@alice'
    end

    it 'returns path for pretty status links' do
      redirector = described_class.new('@alice/123')
      expect(redirector.redirect_path).to eq 'https://example.com/status-123'
    end

    it 'returns path for legacy status links with a query param' do
      redirector = described_class.new('statuses/123?foo=bar')
      expect(redirector.redirect_path).to eq 'https://example.com/status-123'
    end

    it 'returns path for pretty status links with a query param' do
      redirector = described_class.new('@alice/123?foo=bar')
      expect(redirector.redirect_path).to eq 'https://example.com/status-123'
    end

    it 'returns path for deck URLs with query params' do
      redirector = described_class.new('/deck/directory?local=true')
      expect(redirector.redirect_path).to eq '/directory?local=true'
    end
  end
end
