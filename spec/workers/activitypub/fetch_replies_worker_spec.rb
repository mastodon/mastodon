# frozen_string_literal: true

require 'rails_helper'

describe ActivityPub::FetchRepliesWorker do
  subject { described_class.new }

  let(:account) { Fabricate(:account, domain: 'example.com') }
  let(:status)  { Fabricate(:status, account: account) }

  let(:payload) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'https://example.com/statuses_replies/1',
      type: 'Collection',
      items: [],
    }
  end

  let(:json) { Oj.dump(payload) }

  describe 'perform' do
    it 'performs a request if the collection URI is from the same host' do
      stub_request(:get, 'https://example.com/statuses_replies/1').to_return(status: 200, body: json, headers: { 'Content-Type': 'application/activity+json' })
      subject.perform(status.id, 'https://example.com/statuses_replies/1')
      expect(a_request(:get, 'https://example.com/statuses_replies/1')).to have_been_made.once
    end

    it 'does not perform a request if the collection URI is from a different host' do
      stub_request(:get, 'https://other.com/statuses_replies/1').to_return(status: 200)
      subject.perform(status.id, 'https://other.com/statuses_replies/1')
      expect(a_request(:get, 'https://other.com/statuses_replies/1')).to_not have_been_made
    end

    it 'raises when request fails' do
      stub_request(:get, 'https://example.com/statuses_replies/1').to_return(status: 500)
      expect { subject.perform(status.id, 'https://example.com/statuses_replies/1') }.to raise_error Mastodon::UnexpectedResponseError
    end
  end
end
