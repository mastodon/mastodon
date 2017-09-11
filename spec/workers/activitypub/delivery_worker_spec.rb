# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::DeliveryWorker do
  subject { described_class.new }

  let(:sender)  { Fabricate(:account) }
  let(:payload) { 'test' }

  describe 'perform' do
    it 'performs a request' do
      stub_request(:post, 'https://example.com/api').to_return(status: 200)
      subject.perform(payload, sender.id, 'https://example.com/api')
      expect(a_request(:post, 'https://example.com/api')).to have_been_made.once
    end

    it 'raises when request fails' do
      stub_request(:post, 'https://example.com/api').to_return(status: 500)
      expect { subject.perform(payload, sender.id, 'https://example.com/api') }.to raise_error Mastodon::UnexpectedResponseError
    end
  end
end
