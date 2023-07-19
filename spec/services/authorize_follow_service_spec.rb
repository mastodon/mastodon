# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthorizeFollowService, type: :service do
  subject { described_class.new }

  let(:sender) { Fabricate(:account, username: 'alice') }

  describe 'local' do
    let(:bob) { Fabricate(:account, username: 'bob') }

    before do
      FollowRequest.create(account: bob, target_account: sender)
      subject.call(bob, sender)
    end

    it 'removes follow request' do
      expect(bob.requested?(sender)).to be false
    end

    it 'creates follow relation' do
      expect(bob.following?(sender)).to be true
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

    it 'creates follow relation' do
      expect(bob.following?(sender)).to be true
    end

    it 'sends an accept activity' do
      expect(a_request(:post, bob.inbox_url)).to have_been_made.once
    end
  end
end
