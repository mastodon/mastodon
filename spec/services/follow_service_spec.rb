require 'rails_helper'

RSpec.describe FollowService do
  let(:sender) { Fabricate(:account, username: 'alice') }

  subject { FollowService.new }

  context 'local account' do
    describe 'locked account' do
      let(:bob) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, locked: true, username: 'bob')).account }

      before do
        subject.call(sender, bob.acct)
      end

      it 'creates a follow request' do
        expect(FollowRequest.find_by(account: sender, target_account: bob)).to_not be_nil
      end
    end

    describe 'unlocked account' do
      let(:bob) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }

      before do
        subject.call(sender, bob.acct)
      end

      it 'creates a following relation' do
        expect(sender.following?(bob)).to be true
      end
    end

    describe 'already followed account' do
      let(:bob) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, username: 'bob')).account }

      before do
        sender.follow!(bob)
        subject.call(sender, bob.acct)
      end

      it 'keeps a following relation' do
        expect(sender.following?(bob)).to be true
      end
    end
  end

  context 'remote OStatus account' do
    describe 'locked account' do
      let(:bob) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, protocol: :ostatus, locked: true, username: 'bob', domain: 'example.com', salmon_url: 'http://salmon.example.com')).account }

      before do
        stub_request(:post, "http://salmon.example.com/").to_return(:status => 200, :body => "", :headers => {})
        subject.call(sender, bob.acct)
      end

      it 'creates a follow request' do
        expect(FollowRequest.find_by(account: sender, target_account: bob)).to_not be_nil
      end

      it 'sends a follow request salmon slap' do
        expect(a_request(:post, "http://salmon.example.com/").with { |req|
          xml = OStatus2::Salmon.new.unpack(req.body)
          xml.match(TagManager::VERBS[:request_friend])
        }).to have_been_made.once
      end
    end

    describe 'unlocked account' do
      let(:bob) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, protocol: :ostatus, username: 'bob', domain: 'example.com', salmon_url: 'http://salmon.example.com', hub_url: 'http://hub.example.com')).account }

      before do
        stub_request(:post, "http://salmon.example.com/").to_return(:status => 200, :body => "", :headers => {})
        stub_request(:post, "http://hub.example.com/").to_return(status: 202)
        subject.call(sender, bob.acct)
      end

      it 'creates a following relation' do
        expect(sender.following?(bob)).to be true
      end

      it 'sends a follow salmon slap' do
        expect(a_request(:post, "http://salmon.example.com/").with { |req|
          xml = OStatus2::Salmon.new.unpack(req.body)
          xml.match(TagManager::VERBS[:follow])
        }).to have_been_made.once
      end

      it 'subscribes to PuSH' do
        expect(a_request(:post, "http://hub.example.com/")).to have_been_made.once
      end
    end

    describe 'already followed account' do
      let(:bob) { Fabricate(:user, email: 'bob@example.com', account: Fabricate(:account, protocol: :ostatus, username: 'bob', domain: 'example.com', salmon_url: 'http://salmon.example.com', hub_url: 'http://hub.example.com')).account }

      before do
        sender.follow!(bob)
        subject.call(sender, bob.acct)
      end

      it 'keeps a following relation' do
        expect(sender.following?(bob)).to be true
      end

      it 'does not send a follow salmon slap' do
        expect(a_request(:post, "http://salmon.example.com/")).not_to have_been_made
      end

      it 'does not subscribe to PuSH' do
        expect(a_request(:post, "http://hub.example.com/")).not_to have_been_made
      end
    end
  end

  context 'remote ActivityPub account' do
    let(:bob) { Fabricate(:user, account: Fabricate(:account, username: 'bob', domain: 'example.com', protocol: :activitypub, inbox_url: 'http://example.com/inbox')).account }

    before do
      stub_request(:post, "http://example.com/inbox").to_return(:status => 200, :body => "", :headers => {})
      subject.call(sender, bob.acct)
    end

    it 'creates follow request' do
      expect(FollowRequest.find_by(account: sender, target_account: bob)).to_not be_nil
    end

    it 'sends a follow activity to the inbox' do
      expect(a_request(:post, 'http://example.com/inbox')).to have_been_made.once
    end
  end
end
