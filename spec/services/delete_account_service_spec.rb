require 'rails_helper'

RSpec.describe DeleteAccountService, type: :service do
  shared_examples 'common behavior' do
    let!(:status) { Fabricate(:status, account: account) }
    let!(:media_attachment) { Fabricate(:media_attachment, account: account) }
    let!(:notification) { Fabricate(:notification, account: account) }
    let!(:favourite) { Fabricate(:favourite, account: account) }

    before do
      account.follow!(local_follower)
      local_follower.follow!(account)
      AccountPin.create!(account: local_follower, target_account: account)
    end

    subject do
      -> { described_class.new.call(account) }
    end

    it 'deletes associated records' do
      is_expected.to change {
        [
          account.statuses,
          account.media_attachments,
          account.notifications,
          account.favourites,
          account.active_relationships,
          account.passive_relationships,
          AccountPin.where(target_account: account),
        ].map(&:count)
      }.from([1, 1, 1, 1, 1, 1, 1]).to([0, 0, 0, 0, 0, 0, 0])
    end
  end

  describe '#call on local account' do
    before do
      stub_request(:post, "https://alice.com/inbox").to_return(status: 201)
      stub_request(:post, "https://bob.com/inbox").to_return(status: 201)
    end

    let!(:remote_alice) { Fabricate(:account, inbox_url: 'https://alice.com/inbox', protocol: :activitypub) }
    let!(:remote_bob) { Fabricate(:account, inbox_url: 'https://bob.com/inbox', protocol: :activitypub) }

    include_examples 'common behavior' do
      let!(:account) { Fabricate(:account) }
      let!(:local_follower) { Fabricate(:account) }

      it 'sends a delete actor activity to all known inboxes' do
        subject.call
        expect(a_request(:post, "https://alice.com/inbox")).to have_been_made.once
        expect(a_request(:post, "https://bob.com/inbox")).to have_been_made.once
      end
    end
  end

  describe '#call on remote account' do
    before do
      stub_request(:post, "https://alice.com/inbox").to_return(status: 201)
      stub_request(:post, "https://bob.com/inbox").to_return(status: 201)
    end

    include_examples 'common behavior' do
      let!(:account) { Fabricate(:account, inbox_url: 'https://bob.com/inbox', protocol: :activitypub) }
      let!(:local_follower) { Fabricate(:account) }

      it 'sends a reject follow to follwer inboxes' do
        subject.call
        expect(a_request(:post, account.inbox_url)).to have_been_made.once
      end
    end
  end
end
