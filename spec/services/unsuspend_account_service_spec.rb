require 'rails_helper'

RSpec.describe UnsuspendAccountService, type: :service do
  shared_examples 'common behavior' do
    let!(:local_follower) { Fabricate(:user, current_sign_in_at: 1.hour.ago).account }
    let!(:list)           { Fabricate(:list, account: local_follower) }

    subject do
      -> { described_class.new.call(account) }
    end

    before do
      allow(FeedManager.instance).to receive(:merge_into_home).and_return(nil)
      allow(FeedManager.instance).to receive(:merge_into_list).and_return(nil)

      local_follower.follow!(account)
      list.accounts << account

      account.suspend!(origin: :local)
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

    it 'marks account as unsuspended' do
      is_expected.to change { account.suspended? }.from(true).to(false)
    end

    include_examples 'common behavior' do
      let!(:account)         { Fabricate(:account) }
      let!(:remote_follower) { Fabricate(:account, uri: 'https://alice.com', inbox_url: 'https://alice.com/inbox', protocol: :activitypub) }
      let!(:remote_reporter) { Fabricate(:account, uri: 'https://bob.com', inbox_url: 'https://bob.com/inbox', protocol: :activitypub) }
      let!(:report)          { Fabricate(:report, account: remote_reporter, target_account: account) }

      before do
        remote_follower.follow!(account)
      end

      it "merges back into local followers' feeds" do
        subject.call
        expect(FeedManager.instance).to have_received(:merge_into_home).with(account, local_follower)
        expect(FeedManager.instance).to have_received(:merge_into_list).with(account, list)
      end

      it 'sends an update actor to followers and reporters' do
        subject.call
        expect(a_request(:post, remote_follower.inbox_url).with { |req| match_update_actor_request(req, account) }).to have_been_made.once
        expect(a_request(:post, remote_reporter.inbox_url).with { |req| match_update_actor_request(req, account) }).to have_been_made.once
      end
    end
  end

  describe 'unsuspending a remote account' do
    include_examples 'common behavior' do
      let!(:account)                 { Fabricate(:account, domain: 'bob.com', uri: 'https://bob.com', inbox_url: 'https://bob.com/inbox', protocol: :activitypub) }
      let!(:reslove_account_service) { double }

      before do
        allow(ResolveAccountService).to receive(:new).and_return(reslove_account_service)
      end

      context 'when the account is not remotely suspended' do
        before do
          allow(reslove_account_service).to receive(:call).with(account).and_return(account)
        end

        it 're-fetches the account' do
          subject.call
          expect(reslove_account_service).to have_received(:call).with(account)
        end

        it "merges back into local followers' feeds" do
          subject.call
          expect(FeedManager.instance).to have_received(:merge_into_home).with(account, local_follower)
          expect(FeedManager.instance).to have_received(:merge_into_list).with(account, list)
        end

        it 'marks account as unsuspended' do
          is_expected.to change { account.suspended? }.from(true).to(false)
        end
      end

      context 'when the account is remotely suspended' do
        before do
          allow(reslove_account_service).to receive(:call).with(account) do |account|
            account.suspend!(origin: :remote)
            account
          end
        end

        it 're-fetches the account' do
          subject.call
          expect(reslove_account_service).to have_received(:call).with(account)
        end

        it "does not merge back into local followers' feeds" do
          subject.call
          expect(FeedManager.instance).to_not have_received(:merge_into_home).with(account, local_follower)
          expect(FeedManager.instance).to_not have_received(:merge_into_list).with(account, list)
        end

        it 'does not mark the account as unsuspended' do
          is_expected.not_to change { account.suspended? }
        end
      end

      context 'when the account is remotely deleted' do
        before do
          allow(reslove_account_service).to receive(:call).with(account).and_return(nil)
        end

        it 're-fetches the account' do
          subject.call
          expect(reslove_account_service).to have_received(:call).with(account)
        end

        it "does not merge back into local followers' feeds" do
          subject.call
          expect(FeedManager.instance).to_not have_received(:merge_into_home).with(account, local_follower)
          expect(FeedManager.instance).to_not have_received(:merge_into_list).with(account, list)
        end
      end
    end
  end
end
