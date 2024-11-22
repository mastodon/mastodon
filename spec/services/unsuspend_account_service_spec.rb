# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnsuspendAccountService do
  shared_context 'with common context' do
    subject { described_class.new.call(account) }

    let!(:local_follower) { Fabricate(:user, current_sign_in_at: 1.hour.ago).account }
    let!(:list)           { Fabricate(:list, account: local_follower) }

    before do
      allow(FeedManager.instance).to receive_messages(merge_into_home: nil, merge_into_list: nil)

      local_follower.follow!(account)
      list.accounts << account

      account.unsuspend!
    end
  end

  describe 'unsuspending a local account' do
    def match_update_actor_request(req, account)
      json = JSON.parse(req.body)
      actor_id = ActivityPub::TagManager.instance.uri_for(account)
      json['type'] == 'Update' && json['actor'] == actor_id && json['object']['id'] == actor_id && !json['object']['suspended']
    end

    before do
      stub_request(:post, 'https://alice.com/inbox').to_return(status: 201)
      stub_request(:post, 'https://bob.com/inbox').to_return(status: 201)
    end

    it 'does not change the “suspended” flag' do
      expect { subject }.to_not change(account, :suspended?)
    end

    include_examples 'with common context' do
      let!(:account)         { Fabricate(:account) }
      let!(:remote_follower) { Fabricate(:account, uri: 'https://alice.com', inbox_url: 'https://alice.com/inbox', protocol: :activitypub, domain: 'alice.com') }
      let!(:remote_reporter) { Fabricate(:account, uri: 'https://bob.com', inbox_url: 'https://bob.com/inbox', protocol: :activitypub, domain: 'bob.com') }

      before do
        Fabricate(:report, account: remote_reporter, target_account: account)
        remote_follower.follow!(account)
      end

      it 'merges back into feeds of local followers and sends update', :inline_jobs do
        subject

        expect_feeds_merged
        expect_updates_sent
      end

      def expect_feeds_merged
        expect(FeedManager.instance).to have_received(:merge_into_home).with(account, local_follower)
        expect(FeedManager.instance).to have_received(:merge_into_list).with(account, list)
      end

      def expect_updates_sent
        expect(a_request(:post, remote_follower.inbox_url).with { |req| match_update_actor_request(req, account) }).to have_been_made.once
        expect(a_request(:post, remote_reporter.inbox_url).with { |req| match_update_actor_request(req, account) }).to have_been_made.once
      end
    end
  end

  describe 'unsuspending a remote account' do
    include_examples 'with common context' do
      let!(:account)                 { Fabricate(:account, domain: 'bob.com', uri: 'https://bob.com', inbox_url: 'https://bob.com/inbox', protocol: :activitypub) }
      let!(:resolve_account_service) { instance_double(ResolveAccountService) }

      before do
        allow(ResolveAccountService).to receive(:new).and_return(resolve_account_service)
      end

      context 'when the account is not remotely suspended' do
        before do
          allow(resolve_account_service).to receive(:call).with(account).and_return(account)
        end

        it 're-fetches the account, merges feeds, and preserves suspended' do
          expect { subject }
            .to_not change_suspended_flag
          expect_feeds_merged
          expect(resolve_account_service).to have_received(:call).with(account)
        end

        def expect_feeds_merged
          expect(FeedManager.instance).to have_received(:merge_into_home).with(account, local_follower)
          expect(FeedManager.instance).to have_received(:merge_into_list).with(account, list)
        end

        def change_suspended_flag
          change(account, :suspended?)
        end
      end

      context 'when the account is remotely suspended' do
        before do
          allow(resolve_account_service).to receive(:call).with(account) do |account|
            account.suspend!(origin: :remote)
            account
          end
        end

        it 're-fetches the account, does not merge feeds, marks suspended' do
          expect { subject }
            .to change_suspended_to_true
          expect(resolve_account_service).to have_received(:call).with(account)
          expect_feeds_not_merged
        end

        def expect_feeds_not_merged
          expect(FeedManager.instance).to_not have_received(:merge_into_home).with(account, local_follower)
          expect(FeedManager.instance).to_not have_received(:merge_into_list).with(account, list)
        end

        def change_suspended_to_true
          change(account, :suspended?).from(false).to(true)
        end
      end

      context 'when the account is remotely deleted' do
        before do
          allow(resolve_account_service).to receive(:call).with(account).and_return(nil)
        end

        it 're-fetches the account and does not merge feeds' do
          subject

          expect(resolve_account_service).to have_received(:call).with(account)
          expect_feeds_not_merged
        end

        def expect_feeds_not_merged
          expect(FeedManager.instance).to_not have_received(:merge_into_home).with(account, local_follower)
          expect(FeedManager.instance).to_not have_received(:merge_into_list).with(account, list)
        end
      end
    end
  end
end
