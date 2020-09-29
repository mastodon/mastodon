require 'rails_helper'

RSpec.describe DeleteAccountService, type: :service do
  describe '#call on local account' do
    before do
      stub_request(:post, "https://alice.com/inbox").to_return(status: 201)
      stub_request(:post, "https://bob.com/inbox").to_return(status: 201)
    end

    subject do
      -> { described_class.new.call(account) }
    end

    let!(:account) { Fabricate(:account) }
    let!(:status) { Fabricate(:status, account: account) }
    let!(:media_attachment) { Fabricate(:media_attachment, account: account) }
    let!(:notification) { Fabricate(:notification, account: account) }
    let!(:favourite) { Fabricate(:favourite, account: account) }
    let!(:active_relationship) { Fabricate(:follow, account: account) }
    let!(:passive_relationship) { Fabricate(:follow, target_account: account) }
    let!(:remote_alice) { Fabricate(:account, inbox_url: 'https://alice.com/inbox', protocol: :activitypub) }
    let!(:remote_bob) { Fabricate(:account, inbox_url: 'https://bob.com/inbox', protocol: :activitypub) }
    let!(:endorsment) { Fabricate(:account_pin, account: passive_relationship.account, target_account: account) }

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

    it 'sends a delete actor activity to all known inboxes' do
      subject.call
      expect(a_request(:post, "https://alice.com/inbox")).to have_been_made.once
      expect(a_request(:post, "https://bob.com/inbox")).to have_been_made.once
    end
  end

  describe '#call on remote account' do
    before do
      stub_request(:post, "https://alice.com/inbox").to_return(status: 201)
      stub_request(:post, "https://bob.com/inbox").to_return(status: 201)
    end

    subject do
      -> { described_class.new.call(remote_bob) }
    end

    let!(:account) { Fabricate(:account) }
    let!(:remote_alice) { Fabricate(:account, inbox_url: 'https://alice.com/inbox', protocol: :activitypub) }
    let!(:remote_bob) { Fabricate(:account, inbox_url: 'https://bob.com/inbox', protocol: :activitypub) }
    let!(:status) { Fabricate(:status, account: remote_bob) }
    let!(:media_attachment) { Fabricate(:media_attachment, account: remote_bob) }
    let!(:notification) { Fabricate(:notification, account: remote_bob) }
    let!(:favourite) { Fabricate(:favourite, account: remote_bob) }
    let!(:active_relationship) { Fabricate(:follow, account: remote_bob, target_account: account) }
    let!(:passive_relationship) { Fabricate(:follow, target_account: remote_bob) }

    it 'deletes associated records' do
      is_expected.to change {
        [
          remote_bob.statuses,
          remote_bob.media_attachments,
          remote_bob.notifications,
          remote_bob.favourites,
          remote_bob.active_relationships,
          remote_bob.passive_relationships,
        ].map(&:count)
      }.from([1, 1, 1, 1, 1, 1]).to([0, 0, 0, 0, 0, 0])
    end

    it 'sends a reject follow to follwer inboxes' do
      subject.call
      expect(a_request(:post, remote_bob.inbox_url)).to have_been_made.once
    end
  end
end
