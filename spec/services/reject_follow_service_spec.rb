# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RejectFollowService do
  subject { described_class.new }

  let(:sender) { Fabricate(:account, username: 'alice') }

  describe 'local' do
    let(:bob) { Fabricate(:account) }

    before { FollowRequest.create(account: bob, target_account: sender) }

    it 'removes follow request and does not create relation' do
      subject.call(bob, sender)

      expect(bob)
        .to_not be_requested(sender)
      expect(bob)
        .to_not be_following(sender)
    end
  end

  describe 'remote ActivityPub' do
    let(:bob) { Fabricate(:account, username: 'bob', domain: 'example.com', protocol: :activitypub, inbox_url: 'http://example.com/inbox') }

    before do
      FollowRequest.create(account: bob, target_account: sender)
      stub_request(:post, bob.inbox_url).to_return(status: 200)
    end

    it 'removes follow request, does not create relation, sends reject activity', :inline_jobs do
      subject.call(bob, sender)

      expect(bob)
        .to_not be_requested(sender)
      expect(bob)
        .to_not be_following(sender)
      expect(a_request(:post, bob.inbox_url))
        .to have_been_made.once
    end
  end
end
