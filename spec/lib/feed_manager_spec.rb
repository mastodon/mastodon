require 'rails_helper'

RSpec.describe FeedManager do
  describe '#key' do
    subject { FeedManager.instance.key(:home, 1) }

    it 'returns a string' do
      expect(subject).to be_a String
    end
  end

  describe '#filter?' do
    let(:alice) { Fabricate(:account, username: 'alice') }
    let(:bob)   { Fabricate(:account, username: 'bob', domain: 'example.com') }
    let(:jeff)  { Fabricate(:account, username: 'jeff') }

    context 'for home feed' do
      it 'returns false for followee\'s status' do
        status = Fabricate(:status, text: 'Hello world', account: alice)
        bob.follow!(alice)
        expect(FeedManager.instance.filter?(:home, status, bob.id)).to be false
      end

      it 'returns false for reblog by followee' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reblog = Fabricate(:status, reblog: status, account: alice)
        bob.follow!(alice)
        expect(FeedManager.instance.filter?(:home, reblog, bob.id)).to be false
      end

      it 'returns true for reblog by followee of blocked account' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reblog = Fabricate(:status, reblog: status, account: alice)
        bob.follow!(alice)
        bob.block!(jeff)
        expect(FeedManager.instance.filter?(:home, reblog, bob.id)).to be true
      end

      it 'returns true for reblog by followee of muted account' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reblog = Fabricate(:status, reblog: status, account: alice)
        bob.follow!(alice)
        bob.mute!(jeff)
        expect(FeedManager.instance.filter?(:home, reblog, bob.id)).to be true
      end

      it 'returns true for reblog by followee of someone who is blocking recipient' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reblog = Fabricate(:status, reblog: status, account: alice)
        bob.follow!(alice)
        jeff.block!(bob)
        expect(FeedManager.instance.filter?(:home, reblog, bob.id)).to be true
      end

      it 'returns false for reply by followee to another followee' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
        bob.follow!(alice)
        bob.follow!(jeff)
        expect(FeedManager.instance.filter?(:home, reply, bob.id)).to be false
      end

      it 'returns false for reply by followee to recipient' do
        status = Fabricate(:status, text: 'Hello world', account: bob)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
        bob.follow!(alice)
        expect(FeedManager.instance.filter?(:home, reply, bob.id)).to be false
      end

      it 'returns false for reply by followee to self' do
        status = Fabricate(:status, text: 'Hello world', account: alice)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
        bob.follow!(alice)
        expect(FeedManager.instance.filter?(:home, reply, bob.id)).to be false
      end

      it 'returns true for reply by followee to non-followed account' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
        bob.follow!(alice)
        expect(FeedManager.instance.filter?(:home, reply, bob.id)).to be true
      end

      it 'returns false for status by followee mentioning another account' do
        bob.follow!(alice)
        status = PostStatusService.new.call(alice, 'Hey @jeff')
        expect(FeedManager.instance.filter?(:home, status, bob.id)).to be false
      end

      it 'returns true for status by followee mentioning blocked account' do
        bob.block!(jeff)
        bob.follow!(alice)
        status = PostStatusService.new.call(alice, 'Hey @jeff')
        expect(FeedManager.instance.filter?(:home, status, bob.id)).to be true
      end

      it 'returns true for reblog of a personally blocked domain' do
        alice.block_domain!('example.com')
        alice.follow!(jeff)
        status = Fabricate(:status, text: 'Hello world', account: bob)
        reblog = Fabricate(:status, reblog: status, account: jeff)
        expect(FeedManager.instance.filter?(:home, reblog, alice.id)).to be true
      end
    end

    context 'for mentions feed' do
      it 'returns true for status that mentions blocked account' do
        bob.block!(jeff)
        status = PostStatusService.new.call(alice, 'Hey @jeff')
        expect(FeedManager.instance.filter?(:mentions, status, bob.id)).to be true
      end

      it 'returns true for status that replies to a blocked account' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
        bob.block!(jeff)
        expect(FeedManager.instance.filter?(:mentions, reply, bob.id)).to be true
      end

      it 'returns true for status by silenced account who recipient is not following' do
        status = Fabricate(:status, text: 'Hello world', account: alice)
        alice.update(silenced: true)
        expect(FeedManager.instance.filter?(:mentions, status, bob.id)).to be true
      end

      it 'returns false for status by followed silenced account' do
        status = Fabricate(:status, text: 'Hello world', account: alice)
        alice.update(silenced: true)
        bob.follow!(alice)
        expect(FeedManager.instance.filter?(:mentions, status, bob.id)).to be false
      end
    end
  end
end
