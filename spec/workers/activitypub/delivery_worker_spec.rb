# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::DeliveryWorker do
  include RoutingHelper

  let(:sender) { Fabricate(:account) }
  let(:payload) { 'test' }
  let(:url) { 'https://example.com/api' }

  before do
    allow(sender).to receive(:remote_followers_hash).with(url).and_return('somehash')
    allow(Account).to receive(:find).with(sender.id).and_return(sender)
  end

  describe 'perform' do
    it 'performs a request' do
      stub_request(:post, url).to_return(status: 200)
      subject.perform(payload, sender.id, url, { synchronize_followers: true })
      expect(a_request(:post, url).with(headers: { 'Collection-Synchronization' => "collectionId=\"#{account_followers_url(sender)}\", digest=\"somehash\", url=\"#{account_followers_synchronization_url(sender)}\"" })).to have_been_made.once
    end

    it 'raises when request fails' do
      stub_request(:post, url).to_return(status: 500)
      expect { subject.perform(payload, sender.id, url) }.to raise_error Mastodon::UnexpectedResponseError
    end
  end
end
