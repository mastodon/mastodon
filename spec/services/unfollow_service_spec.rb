# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnfollowService do
  subject { described_class.new }

  let(:sender) { Fabricate(:account, username: 'alice') }

  describe 'local' do
    let(:bob) { Fabricate(:account, username: 'bob') }

    before { sender.follow!(bob) }

    it 'destroys the following relation' do
      subject.call(sender, bob)

      expect(sender)
        .to_not be_following(bob)
    end
  end

  describe 'remote ActivityPub', :inline_jobs do
    let(:bob) { Fabricate(:account, username: 'bob', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

    before do
      sender.follow!(bob)
      stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
    end

    it 'destroys the following relation and sends unfollow activity' do
      subject.call(sender, bob)

      expect(sender)
        .to_not be_following(bob)
      expect(a_request(:post, 'http://example.com/inbox'))
        .to have_been_made.once
    end
  end

  describe 'remote ActivityPub (reverse)', :inline_jobs do
    let(:bob) { Fabricate(:account, username: 'bob', protocol: :activitypub, domain: 'example.com', inbox_url: 'http://example.com/inbox') }

    before do
      bob.follow!(sender)
      stub_request(:post, 'http://example.com/inbox').to_return(status: 200)
    end

    it 'destroys the following relation and sends a reject activity' do
      subject.call(bob, sender)

      expect(sender)
        .to_not be_following(bob)
      expect(a_request(:post, 'http://example.com/inbox'))
        .to have_been_made.once
    end
  end
end
