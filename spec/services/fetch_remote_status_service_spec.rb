require 'rails_helper'

RSpec.describe FetchRemoteStatusService, type: :service do
  let(:account) { Fabricate(:account) }
  let(:prefetched_body) { nil }
  let(:valid_domain) { Rails.configuration.x.local_domain }

  let(:note) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: "https://#{valid_domain}/@foo/1234",
      type: 'Note',
      content: 'Lorem ipsum',
      attributedTo: ActivityPub::TagManager.instance.uri_for(account),
    }
  end

  context 'protocol is :activitypub' do
    subject { described_class.new.call(note[:id], prefetched_body, protocol) }
    let(:prefetched_body) { Oj.dump(note) }
    let(:protocol) { :activitypub }

    before do
      account.update(uri: ActivityPub::TagManager.instance.uri_for(account))
      subject
    end

    it 'creates status' do
      status = account.statuses.first

      expect(status).to_not be_nil
      expect(status.text).to eq 'Lorem ipsum'
    end
  end
end
