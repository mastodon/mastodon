# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthorizeFollowService do
  subject { described_class.new }

  let(:sender) { Fabricate(:account, username: 'alice') }

  describe 'local' do
    let(:bob) { Fabricate(:account, username: 'bob') }

    before do
      FollowRequest.create(account: bob, target_account: sender)
    end

    it 'removes follow request and creates follow relation' do
      subject.call(bob, sender)

      expect(bob)
        .to_not be_requested(sender)
      expect(bob)
        .to be_following(sender)
    end
  end

  describe 'remote ActivityPub' do
    let(:bob) { Fabricate(:account, username: 'bob', domain: 'example.com', protocol: :activitypub, inbox_url: 'http://example.com/inbox') }

    before do
      FollowRequest.create(account: bob, target_account: sender)
      stub_request(:post, bob.inbox_url).to_return(status: 200)
    end

    it 'removes follow request, creates follow relation, send accept activity', :inline_jobs do
      subject.call(bob, sender)

      expect(bob)
        .to_not be_requested(sender)
      expect(bob)
        .to be_following(sender)
      expect(a_request(:post, bob.inbox_url))
        .to have_been_made.once
    end
  end
end
