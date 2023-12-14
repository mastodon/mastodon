# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteAccountService, type: :service do
  shared_examples 'common behavior' do
    subject { described_class.new.call(account) }

    let!(:status) { Fabricate(:status, account: account) }
    let!(:mention) { Fabricate(:mention, account: local_follower) }
    let!(:favourite) { Fabricate(:favourite, account: account, status: Fabricate(:status, account: local_follower)) }
    let!(:poll) { Fabricate(:poll, account: account) }
    let!(:active_relationship) { Fabricate(:follow, account: account, target_account: local_follower) }

    before do
      Fabricate(:status, account: account, mentions: [mention])
      Fabricate(:media_attachment, account: account)
      Fabricate(:notification, account: account)
      Fabricate(:poll_vote, account: local_follower, poll: poll)
      Fabricate(:follow, account: local_follower, target_account: account)
      Fabricate(:account_pin, account: local_follower, target_account: account)
      Fabricate(:notification, account: local_follower, activity: mention, type: :mention)
      Fabricate(:notification, account: local_follower, activity: status, type: :status)
      Fabricate(:notification, account: local_follower, activity: poll, type: :poll)
      Fabricate(:notification, account: local_follower, activity: favourite, type: :favourite)
      Fabricate(:notification, account: local_follower, activity: active_relationship, type: :follow)
      Fabricate(:account_note, account: account)
    end

    it 'deletes associated owned and target records and target notifications' do
      expect { subject }
        .to delete_associated_owned_records
        .and delete_associated_target_records
        .and delete_associated_target_notifications
    end

    def delete_associated_owned_records
      change do
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
      end.from([2, 1, 1, 1, 1, 1, 1, 1]).to([0, 0, 0, 0, 0, 0, 0, 0])
    end

    def delete_associated_target_records
      change(account_pins_for_account, :count).from(1).to(0)
    end

    def account_pins_for_account
      AccountPin.where(target_account: account)
    end

    def delete_associated_target_notifications
      change do
        %w(
          poll favourite status mention follow
        ).map { |type| Notification.where(type: type).count }
      end.from([1, 1, 1, 1, 1]).to([0, 0, 0, 0, 0])
    end
  end

  describe '#call on local account' do
    before do
      Fabricate(:account, inbox_url: 'https://alice.com/inbox', domain: 'alice.com', protocol: :activitypub)
      Fabricate(:account, inbox_url: 'https://bob.com/inbox', domain: 'bob.com', protocol: :activitypub)
      stub_request(:post, 'https://alice.com/inbox').to_return(status: 201)
      stub_request(:post, 'https://bob.com/inbox').to_return(status: 201)
    end

    include_examples 'common behavior' do
      # rubocop:disable RSpec/LetSetup
      let!(:account) { Fabricate(:account) }
      let!(:local_follower) { Fabricate(:account) }
      # rubocop:enable RSpec/LetSetup

      it 'sends a delete actor activity to all known inboxes' do
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
      let!(:account) { Fabricate(:account, inbox_url: 'https://bob.com/inbox', protocol: :activitypub, domain: 'bob.com') }
      let!(:local_follower) { Fabricate(:account) }

      it 'sends expected activities to followed and follower inboxes' do
        subject

        expect(post_to_inbox_with_reject).to have_been_made.once
        expect(post_to_inbox_with_undo).to have_been_made.once
      end

      def post_to_inbox_with_undo
        a_request(:post, account.inbox_url).with(
          body: hash_including({
            'type' => 'Undo',
            'object' => hash_including({
              'type' => 'Follow',
              'actor' => ActivityPub::TagManager.instance.uri_for(local_follower),
              'object' => account.uri,
            }),
          })
        )
      end

      def post_to_inbox_with_reject
        a_request(:post, account.inbox_url).with(
          body: hash_including({
            'type' => 'Reject',
            'object' => hash_including({
              'type' => 'Follow',
              'actor' => account.uri,
              'object' => ActivityPub::TagManager.instance.uri_for(local_follower),
            }),
          })
        )
      end
    end
  end
end
