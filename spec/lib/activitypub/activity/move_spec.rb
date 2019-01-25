require 'rails_helper'

RSpec.describe ActivityPub::Activity::Move do
  let(:follower)    { Fabricate(:account) }
  let(:old_account) { Fabricate(:account) }
  let(:new_account) { Fabricate(:account) }

  before do
    follower.follow!(old_account)

    old_account.update!(uri: 'https://example.org/alice', domain: 'example.org', protocol: :activitypub, inbox_url: 'https://example.org/inbox')
    new_account.update!(uri: 'https://example.com/alice', domain: 'example.com', protocol: :activitypub, inbox_url: 'https://example.com/inbox', also_known_as: [old_account.uri])

    stub_request(:post, 'https://example.org/inbox').to_return(status: 200)
    stub_request(:post, 'https://example.com/inbox').to_return(status: 200)

    service_stub = double
    allow(ActivityPub::FetchRemoteAccountService).to receive(:new).and_return(service_stub)
    allow(service_stub).to receive(:call).and_return(new_account)
  end

  let(:json) do
    {
      '@context': 'https://www.w3.org/ns/activitystreams',
      id: 'foo',
      type: 'Move',
      actor: old_account.uri,
      object: old_account.uri,
      target: new_account.uri,
    }.with_indifferent_access
  end

  describe '#perform' do
    subject { described_class.new(json, old_account) }

    before do
      subject.perform
    end

    it 'sets moved account on old account' do
      expect(old_account.reload.moved_to_account_id).to eq new_account.id
    end

    it 'makes followers unfollow old account' do
      expect(follower.following?(old_account)).to be false
    end

    it 'makes followers follow-request the new account' do
      expect(follower.requested?(new_account)).to be true
    end
  end
end
