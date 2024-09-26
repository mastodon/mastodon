# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FollowService do
  subject { described_class.new }

  let(:sender) { Fabricate(:account, username: 'alice') }

  context 'when local account' do
    describe 'locked account' do
      let(:bob) { Fabricate(:account, locked: true, username: 'bob') }

      before do
        subject.call(sender, bob)
      end

      it 'creates a follow request with reblogs' do
        expect(FollowRequest.find_by(account: sender, target_account: bob, show_reblogs: true)).to_not be_nil
      end
    end

    describe 'locked account, no reblogs' do
      let(:bob) { Fabricate(:account, locked: true, username: 'bob') }

      before do
        subject.call(sender, bob, reblogs: false)
      end

      it 'creates a follow request without reblogs' do
        expect(FollowRequest.find_by(account: sender, target_account: bob, show_reblogs: false)).to_not be_nil
      end
    end

    describe 'unlocked account, from silenced account' do
      let(:bob) { Fabricate(:account, username: 'bob') }

      before do
        sender.touch(:silenced_at)
        subject.call(sender, bob)
      end

      it 'creates a follow request with reblogs' do
        expect(FollowRequest.find_by(account: sender, target_account: bob, show_reblogs: true)).to_not be_nil
      end
    end

    describe 'unlocked account, from a muted account' do
      let(:bob) { Fabricate(:account, username: 'bob') }

      before do
        bob.mute!(sender)
        subject.call(sender, bob)
      end

      it 'creates a following relation with reblogs' do
        expect(sender.following?(bob)).to be true
        expect(sender.muting_reblogs?(bob)).to be false
      end
    end

    describe 'unlocked account' do
      let(:bob) { Fabricate(:account, username: 'bob') }

      before do
        subject.call(sender, bob)
      end

      it 'creates a following relation with reblogs' do
        expect(sender.following?(bob)).to be true
        expect(sender.muting_reblogs?(bob)).to be false
      end
    end

    describe 'unlocked account, no reblogs' do
      let(:bob) { Fabricate(:account, username: 'bob') }

      before do
        subject.call(sender, bob, reblogs: false)
      end

      it 'creates a following relation without reblogs' do
        expect(sender.following?(bob)).to be true
        expect(sender.muting_reblogs?(bob)).to be true
      end
    end

    describe 'already followed account' do
      let(:bob) { Fabricate(:account, username: 'bob') }

      before do
        sender.follow!(bob)
        subject.call(sender, bob)
      end

      it 'keeps a following relation' do
        expect(sender.following?(bob)).to be true
      end
    end

    describe 'already followed account, turning reblogs off' do
      let(:bob) { Fabricate(:account, username: 'bob') }

      before do
        sender.follow!(bob, reblogs: true)
        subject.call(sender, bob, reblogs: false)
      end

      it 'disables reblogs' do
        expect(sender.muting_reblogs?(bob)).to be true
      end
    end

    describe 'already followed account, turning reblogs on' do
      let(:bob) { Fabricate(:account, username: 'bob') }

      before do
        sender.follow!(bob, reblogs: false)
        subject.call(sender, bob, reblogs: true)
      end

      it 'disables reblogs' do
        expect(sender.muting_reblogs?(bob)).to be false
      end
    end

    describe 'already followed account, changing languages' do
      let(:bob) { Fabricate(:account, username: 'bob') }

      before do
        sender.follow!(bob)
        subject.call(sender, bob, languages: %w(en es))
      end

      it 'changes languages' do
        expect(Follow.find_by(account: sender, target_account: bob)&.languages).to match_array %w(en es)
      end
    end
  end

  context 'when remote ActivityPub account' do
    let(:bob) { Fabricate(:account, username: 'bob', domain: 'example.com', protocol: :activitypub, inbox_url: 'http://example.com/inbox') }

    before do
      stub_request(:post, 'http://example.com/inbox').to_return(status: 200, body: '', headers: {})
      subject.call(sender, bob)
    end

    it 'creates follow request' do
      expect(FollowRequest.find_by(account: sender, target_account: bob)).to_not be_nil
    end

    it 'sends a follow activity to the inbox', :inline_jobs do
      expect(a_request(:post, 'http://example.com/inbox')).to have_been_made.once
    end
  end
end
