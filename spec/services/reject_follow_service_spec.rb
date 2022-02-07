require 'rails_helper'

RSpec.describe RejectFollowService, type: :service do
  let(:sender) { Fabricate(:account, username: 'alice') }

  subject { RejectFollowService.new }

  describe 'local' do
    let(:bob) { Fabricate(:account) }

    before do
      FollowRequest.create(account: bob, target_account: sender)
      subject.call(bob, sender)
    end

    it 'removes follow request' do
      expect(bob.requested?(sender)).to be false
    end

    it 'does not create follow relation' do
      expect(bob.following?(sender)).to be false
    end
  end

  describe 'remote ActivityPub' do
    let(:bob) { Fabricate(:account, username: 'bob', domain: 'example.com', protocol: :activitypub, inbox_url: 'http://example.com/inbox') }

    before do
      FollowRequest.create(account: bob, target_account: sender)
      stub_request(:post, bob.inbox_url).to_return(status: 200)
      subject.call(bob, sender)
    end

    it 'removes follow request' do
      expect(bob.requested?(sender)).to be false
    end

    it 'does not create follow relation' do
      expect(bob.following?(sender)).to be false
    end

    it 'sends a reject activity' do
      expect(a_request(:post, bob.inbox_url)).to have_been_made.once
    end
  end
end
