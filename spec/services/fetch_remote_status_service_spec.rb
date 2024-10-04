# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FetchRemoteStatusService do
  let(:account) { Fabricate(:account, domain: 'example.org', uri: 'https://example.org/foo') }
  let(:prefetched_body) { nil }

  let(:note) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'https://example.org/@foo/1234',
      type: 'Note',
      content: 'Lorem ipsum',
      attributedTo: ActivityPub::TagManager.instance.uri_for(account),
    }
  end

  context 'when protocol is :activitypub' do
    subject { described_class.new.call(note[:id], prefetched_body: prefetched_body) }

    let(:prefetched_body) { Oj.dump(note) }

    before do
      subject
    end

    it 'creates status' do
      status = account.statuses.first

      expect(status).to_not be_nil
      expect(status.text).to eq 'Lorem ipsum'
    end
  end
end
