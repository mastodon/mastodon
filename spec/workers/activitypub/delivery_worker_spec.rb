# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::DeliveryWorker do
  include RoutingHelper

  subject { described_class.new }

  let(:sender)  { Fabricate(:account) }
  let(:payload) { 'test' }

  before do
    allow(sender).to receive(:remote_followers_hash).with('https://example.com/api').and_return('somehash')
    allow(Account).to receive(:find).with(sender.id).and_return(sender)
  end

  describe 'perform' do
    it 'performs a request' do
      stub_request(:post, 'https://example.com/api').to_return(status: 200)
      subject.perform(payload, sender.id, 'https://example.com/api', { synchronize_followers: true })
      expect(a_request(:post, 'https://example.com/api').with(headers: { 'Collection-Synchronization' => "collectionId=\"#{account_followers_url(sender)}\", digest=\"somehash\", url=\"#{account_followers_synchronization_url(sender)}\"" })).to have_been_made.once
    end

    it 'raises when request fails' do
      stub_request(:post, 'https://example.com/api').to_return(status: 500)
      expect { subject.perform(payload, sender.id, 'https://example.com/api') }.to raise_error Mastodon::UnexpectedResponseError
    end
  end
end
