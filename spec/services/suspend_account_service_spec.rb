# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SuspendAccountService, :inline_jobs do
  shared_examples 'common behavior' do
    subject { described_class.new.call(account) }

    let!(:local_follower) { Fabricate(:user, current_sign_in_at: 1.hour.ago).account }
    let!(:list)           { Fabricate(:list, account: local_follower) }

    before do
      allow(FeedManager.instance).to receive_messages(unmerge_from_home: nil, unmerge_from_list: nil)

      local_follower.follow!(account)
      list.accounts << account

      account.suspend!

      Fabricate(:media_attachment, file: attachment_fixture('boop.ogg'), account: account)
    end

    it 'unmerges from feeds of local followers and changes file mode and preserves suspended flag' do
      expect { subject }
        .to change_file_mode
        .and not_change_suspended_flag
      expect(FeedManager.instance).to have_received(:unmerge_from_home).with(account, local_follower)
      expect(FeedManager.instance).to have_received(:unmerge_from_list).with(account, list)
    end

    def change_file_mode
      change { File.stat(account.media_attachments.first.file.path).mode }
    end

    def not_change_suspended_flag
      not_change(account, :suspended?)
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
      let!(:remote_follower) { Fabricate(:account, uri: 'https://alice.com', inbox_url: 'https://alice.com/inbox', protocol: :activitypub, domain: 'alice.com') }
      let!(:remote_reporter) { Fabricate(:account, uri: 'https://bob.com', inbox_url: 'https://bob.com/inbox', protocol: :activitypub, domain: 'bob.com') }

      before do
        Fabricate(:report, account: remote_reporter, target_account: account)
        remote_follower.follow!(account)
      end

      it 'sends an Update actor activity to followers and reporters' do
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

      it 'sends a Reject Follow activity', :aggregate_failures do
        subject

        expect(a_request(:post, account.inbox_url).with { |req| match_reject_follow_request(req, account, local_followee) }).to have_been_made.once
      end
    end
  end
end
