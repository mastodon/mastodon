require 'rails_helper'

RSpec.describe SuspendAccountService, type: :service do
  shared_examples 'common behavior' do
    let!(:local_follower) { Fabricate(:user, current_sign_in_at: 1.hour.ago).account }
    let!(:list)           { Fabricate(:list, account: local_follower) }

    subject { described_class.new.call(account) }

    before do
      allow(FeedManager.instance).to receive_messages(unmerge_from_home: nil, unmerge_from_list: nil)
      allow(Rails.configuration.x).to receive(:cache_buster_enabled).and_return(true)
      allow(CacheBusterWorker).to receive(:perform_async)

      local_follower.follow!(account)
      list.accounts << account

      account.suspend!

      Fabricate(:media_attachment, file: attachment_fixture('boop.ogg'), account: account)
    end

    it 'unmerges from feeds of local followers and changes file mode' do
      expect { subject }
        .to change { File.stat(account.media_attachments.first.file.path).mode }

      expect(CacheBusterWorker).to have_received(:perform_async).with(account.media_attachments.first.file.url(:original))
      expect(FeedManager.instance).to have_received(:unmerge_from_home).with(account, local_follower)
      expect(FeedManager.instance).to have_received(:unmerge_from_list).with(account, list)
    end

    it 'does not change the “suspended” flag' do
      expect { subject }.to_not change { account.suspended? }
    end
  end

  describe 'suspending a local account' do
    def match_update_actor_request(req, account)
      json = JSON.parse(req.body)
      actor_id = ActivityPub::TagManager.instance.uri_for(account)
      json['type'] == 'Update' && json['actor'] == actor_id && json['object']['id'] == actor_id && json['object']['suspended']
    end

    before do
      stub_request(:post, 'https://alice.com/inbox').to_return(status: 201)
      stub_request(:post, 'https://bob.com/inbox').to_return(status: 201)
    end

    include_examples 'common behavior' do
      let!(:account)         { Fabricate(:account) }
      let!(:remote_follower) { Fabricate(:account, uri: 'https://alice.com', inbox_url: 'https://alice.com/inbox', protocol: :activitypub) }
      let!(:remote_reporter) { Fabricate(:account, uri: 'https://bob.com', inbox_url: 'https://bob.com/inbox', protocol: :activitypub) }
      let!(:report)          { Fabricate(:report, account: remote_reporter, target_account: account) }

      before do
        remote_follower.follow!(account)
      end

      it 'sends an update actor to followers and reporters' do
        subject

        expect(a_request(:post, remote_follower.inbox_url).with { |req| match_update_actor_request(req, account) }).to have_been_made.once
        expect(a_request(:post, remote_reporter.inbox_url).with { |req| match_update_actor_request(req, account) }).to have_been_made.once
      end
    end
  end

  describe 'suspending a remote account' do
    def match_reject_follow_request(req, account, followee)
      json = JSON.parse(req.body)
      json['type'] == 'Reject' && json['actor'] == ActivityPub::TagManager.instance.uri_for(followee) && json['object']['actor'] == account.uri
    end

    before do
      stub_request(:post, 'https://bob.com/inbox').to_return(status: 201)
    end

    include_examples 'common behavior' do
      let!(:account)        { Fabricate(:account, domain: 'bob.com', uri: 'https://bob.com', inbox_url: 'https://bob.com/inbox', protocol: :activitypub) }
      let!(:local_followee) { Fabricate(:account) }

      before do
        account.follow!(local_followee)
      end

      it 'sends a reject follow' do
        subject

        expect(a_request(:post, account.inbox_url).with { |req| match_reject_follow_request(req, account, local_followee) }).to have_been_made.once
      end
    end
  end
end
