# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteAccountService, type: :service do
  shared_examples 'common behavior' do
    subject { described_class.new.call(account) }

    before do
      _status_with_mention = Fabricate(:status, account: account, mentions: [mention])
      _media_attachment = Fabricate(:media_attachment, account: account)
      _notification = Fabricate(:notification, account: account)
      _poll_vote = Fabricate(:poll_vote, account: local_follower, poll: poll)
      _passive_relationship = Fabricate(:follow, account: local_follower, target_account: account)
      _endorsement = Fabricate(:account_pin, account: local_follower, target_account: account)
      _mention_notification = Fabricate(:notification, account: local_follower, activity: mention, type: :mention)
      _status_notification = Fabricate(:notification, account: local_follower, activity: status, type: :status)
      _poll_notification = Fabricate(:notification, account: local_follower, activity: poll, type: :poll)
      _favourite_notification = Fabricate(:notification, account: local_follower, activity: favourite, type: :favourite)
      _follow_notification = Fabricate(:notification, account: local_follower, activity: active_relationship, type: :follow)
      _account_note = Fabricate(:account_note, account: account)
    end

    let!(:status) { Fabricate(:status, account: account) }
    let!(:mention) { Fabricate(:mention, account: local_follower) }
    let!(:favourite) { Fabricate(:favourite, account: account, status: Fabricate(:status, account: local_follower)) }
    let!(:poll) { Fabricate(:poll, account: account) }
    let!(:active_relationship) { Fabricate(:follow, account: account, target_account: local_follower) }

    it 'deletes associated owned records' do
      expect { subject }.to change {
        [
          account.statuses,
          account.media_attachments,
          account.notifications,
          account.favourites,
          account.active_relationships,
          account.passive_relationships,
          account.polls,
          account.account_notes,
        ].map(&:count)
      }.from([2, 1, 1, 1, 1, 1, 1, 1]).to([0, 0, 0, 0, 0, 0, 0, 0])
    end

    it 'deletes associated target records' do
      expect { subject }.to change {
        [
          AccountPin.where(target_account: account),
        ].map(&:count)
      }.from([1]).to([0])
    end

    it 'deletes associated target notifications' do
      expect { subject }.to change {
        %w(
          poll favourite status mention follow
        ).map { |type| Notification.where(type: type).count }
      }.from([1, 1, 1, 1, 1]).to([0, 0, 0, 0, 0])
    end
  end

  describe '#call on local account' do
    before do
      stub_request(:post, 'https://alice.com/inbox').to_return(status: 201)
      stub_request(:post, 'https://bob.com/inbox').to_return(status: 201)
      _remote_alice = Fabricate(:account, inbox_url: 'https://alice.com/inbox', protocol: :activitypub)
      _remote_bob = Fabricate(:account, inbox_url: 'https://bob.com/inbox', protocol: :activitypub)
    end

    include_examples 'common behavior' do
      let!(:account) { Fabricate(:account) }
      let!(:local_follower) { Fabricate(:account) }

      it 'sends a delete actor activity to all known inboxes' do
        expect(account).to be_local
        expect(local_follower).to be_local

        subject
        expect(a_request(:post, 'https://alice.com/inbox')).to have_been_made.once
        expect(a_request(:post, 'https://bob.com/inbox')).to have_been_made.once
      end
    end
  end

  describe '#call on remote account' do
    before do
      stub_request(:post, 'https://alice.com/inbox').to_return(status: 201)
      stub_request(:post, 'https://bob.com/inbox').to_return(status: 201)
    end

    include_examples 'common behavior' do
      let!(:account) { Fabricate(:account, inbox_url: 'https://bob.com/inbox', protocol: :activitypub) }
      let!(:local_follower) { Fabricate(:account) }

      it 'sends a reject follow to follower inboxes' do
        expect(local_follower).to be_local

        subject
        expect(a_request(:post, account.inbox_url)).to have_been_made.once
      end
    end
  end
end
