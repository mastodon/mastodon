require 'rails_helper'

RSpec.describe ActivityPub::Activity::Move do
  let(:follower)         { Fabricate(:account) }
  let(:old_account)      { Fabricate(:account, uri: 'https://example.org/alice', domain: 'example.org', protocol: :activitypub, inbox_url: 'https://example.org/inbox') }
  let(:new_account)      { Fabricate(:account, uri: 'https://example.com/alice', domain: 'example.com', protocol: :activitypub, inbox_url: 'https://example.com/inbox', also_known_as: also_known_as) }
  let(:also_known_as)    { [old_account.uri] }
  let(:returned_account) { new_account }

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

  before do
    follower.follow!(old_account)

    stub_request(:post, old_account.inbox_url).to_return(status: 200)
    stub_request(:post, new_account.inbox_url).to_return(status: 200)

    service_stub = double
    allow(ActivityPub::FetchRemoteAccountService).to receive(:new).and_return(service_stub)
    allow(service_stub).to receive(:call).and_return(returned_account)
  end

  describe '#perform' do
    subject { described_class.new(json, old_account) }

    before do
      subject.perform
    end

    context 'when all conditions are met' do
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

    context "when the new account can't be resolved" do
      let(:returned_account) { nil }

      it 'does not set moved account on old account' do
        expect(old_account.reload.moved_to_account_id).to be_nil
      end

      it 'does not make followers unfollow old account' do
        expect(follower.following?(old_account)).to be true
      end

      it 'does not make followers follow-request the new account' do
        expect(follower.requested?(new_account)).to be false
      end
    end

    context 'when the new account does not references the old account' do
      let(:also_known_as) { [] }

      it 'does not set moved account on old account' do
        expect(old_account.reload.moved_to_account_id).to be_nil
      end

      it 'does not make followers unfollow old account' do
        expect(follower.following?(old_account)).to be true
      end

      it 'does not make followers follow-request the new account' do
        expect(follower.requested?(new_account)).to be false
      end
    end

    context 'when a Move has been recently processed' do
      around do |example|
        Redis.current.set("move_in_progress:#{old_account.id}", true, nx: true, ex: 7.days.seconds)
        example.run
        Redis.current.del("move_in_progress:#{old_account.id}")
      end

      it 'does not set moved account on old account' do
        expect(old_account.reload.moved_to_account_id).to be_nil
      end

      it 'does not make followers unfollow old account' do
        expect(follower.following?(old_account)).to be true
      end

      it 'does not make followers follow-request the new account' do
        expect(follower.requested?(new_account)).to be false
      end
    end
  end
end
