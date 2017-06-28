require 'rails_helper'

RSpec.describe FeedManager do
  let(:alice) { Fabricate(:account, username: 'alice') }
  let(:bob)   { Fabricate(:account, username: 'bob', domain: 'example.com') }
  let(:jeff)  { Fabricate(:account, username: 'jeff') }

  describe '#key' do
    subject { FeedManager.instance.key(:home, 1) }

    it 'returns a string' do
      expect(subject).to be_a String
    end
  end

  describe '#filter_subscribers' do
    it 'does not filter followers' do
      status = Fabricate(:status, text: 'Hello world', account: alice)
      bob.follow!(alice)
      expect(FeedManager.instance.filter_subscribers(status, Account.where(id: bob.id))).to match_array([bob])
    end

    it 'does not filter followers of the account who reblogged' do
      status = Fabricate(:status, text: 'Hello world', account: jeff)
      reblog = Fabricate(:status, reblog: status, account: alice)
      bob.follow!(alice)
      expect(FeedManager.instance.filter_subscribers(reblog, Account.where(id: bob.id))).to match_array([bob])
    end

    it 'filters accounts blocking a follower of the account who reblogged' do
      status = Fabricate(:status, text: 'Hello world', account: jeff)
      reblog = Fabricate(:status, reblog: status, account: alice)
      bob.follow!(alice)
      bob.block!(jeff)
      expect(FeedManager.instance.filter_subscribers(reblog, Account.where(id: bob.id))).to be_empty
    end

    it 'filters accounts muting a follower of the account who reblogged' do
      status = Fabricate(:status, text: 'Hello world', account: jeff)
      reblog = Fabricate(:status, reblog: status, account: alice)
      bob.follow!(alice)
      bob.mute!(jeff)
      expect(FeedManager.instance.filter_subscribers(reblog, Account.where(id: bob.id))).to be_empty
    end

    it 'filters blocked followers of the account who reblogged' do
      status = Fabricate(:status, text: 'Hello world', account: jeff)
      reblog = Fabricate(:status, reblog: status, account: alice)
      bob.follow!(alice)
      jeff.block!(bob)
      expect(FeedManager.instance.filter_subscribers(reblog, Account.where(id: bob))).to be_empty
    end

    it 'does not filter accounts following both of the sender and the recipient of reply' do
      status = Fabricate(:status, text: 'Hello world', account: jeff)
      reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
      bob.follow!(alice)
      bob.follow!(jeff)
      expect(FeedManager.instance.filter_subscribers(reply, Account.where(id: bob.id))).to match_array([bob])
    end

    it 'does not filter the recipient of reply following the sender' do
      status = Fabricate(:status, text: 'Hello world', account: bob)
      reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
      bob.follow!(alice)
      expect(FeedManager.instance.filter_subscribers(reply, Account.where(id: bob.id))).to match_array([bob])
    end

    it 'does not filter followers of the author of self-reply' do
      status = Fabricate(:status, text: 'Hello world', account: alice)
      reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
      bob.follow!(alice)
      expect(FeedManager.instance.filter_subscribers(reply, Account.where(id: bob.id))).to match_array([bob])
    end

    it 'filters accounts following the author of reply but not following the recipient' do
      status = Fabricate(:status, text: 'Hello world', account: jeff)
      reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
      bob.follow!(alice)
      expect(FeedManager.instance.filter_subscribers(reply, Account.where(id: bob.id))).to be_empty
    end

    it 'does not filter followers of the author mentioning another account' do
      bob.follow!(alice)
      status = PostStatusService.new.call(alice, 'Hey @jeff')
      expect(FeedManager.instance.filter_subscribers(status, Account.where(id: bob.id))).to match_array([bob])
    end

    it 'filters followers blocking account mentioned by the author' do
      bob.block!(jeff)
      bob.follow!(alice)
      status = PostStatusService.new.call(alice, 'Hey @jeff')
      expect(FeedManager.instance.filter_subscribers(status, Account.where(id: bob.id))).to be_empty
    end

    it 'filters accounts personally blocking the domain of the account who reblogged' do
      alice.block_domain!('example.com')
      alice.follow!(jeff)
      status = Fabricate(:status, text: 'Hello world', account: bob)
      reblog = Fabricate(:status, reblog: status, account: jeff)
      expect(FeedManager.instance.filter_subscribers(reblog, Account.where(id: alice.id))).to be_empty
    end
  end

  describe '#filter_mentions' do
    it 'filters accounts blocking another mentioned' do
      bob.block!(jeff)
      status = Fabricate(:status, text: 'Hey @bob @jeff', account: alice)
      filtered = Fabricate(:mention, account: bob, status: status)
      unfiltered = Fabricate(:mention, account: jeff, status: status)
      expect(FeedManager.instance.filter_mentions(status)).to match_array([unfiltered])
    end

    it 'filters accounts blocking the recipient of reply' do
      status = Fabricate(:status, text: 'Hello world', account: jeff)
      reply  = Fabricate(:status, text: '@bob Nay', thread: status, account: alice)
      Fabricate(:mention, account: bob, status: reply)
      bob.block!(jeff)
      expect(FeedManager.instance.filter_mentions(reply)).to be_empty
    end

    it 'filters accounts not following the author, who is silenced' do
      status = Fabricate(:status, text: '@bob Hello world', account: alice)
      Fabricate(:mention, account: bob, status: status)
      alice.update(silenced: true)
      expect(FeedManager.instance.filter_mentions(status)).to be_empty
    end

    it 'does not filter accounts following the author, who is silenced' do
      status = Fabricate(:status, text: '@bob Hello world', account: alice)
      mention = Fabricate(:mention, account: bob, status: status)
      alice.update(silenced: true)
      bob.follow!(alice)
      expect(FeedManager.instance.filter_mentions(status)).to match_array([mention])
    end
  end

  describe '#push' do
    let(:account) { Fabricate(:account) }
    let(:status) { Fabricate(:status) }

    it 'pushes status' do
      FeedManager.instance.push_bulk('type', [account], status)
      expect(Redis.current.zscore("feed:type:#{account.id}", status.id)).to eq status.id
    end
  end

  describe '#push_bulk' do
    def expect_to_publish(account, status)
      Fabricate(:status, account: account, reblog: status)

      expect(Redis.current).to receive(:publish) do |channel, message|
        expect(channel).to eq "timeline:#{account.id}"
        expect(message).to include '\"reblogged\":true'
        expect(message).to include "\\\"id\\\":#{status.id}"
      end
    end

    def expect_not_to_publish
      expect(Redis.current).not_to receive(:publish)
    end

    let(:account) { Fabricate(:account) }

    context 'when status is reblog' do
      let(:reblog) { Fabricate(:status) }
      let(:status) { Fabricate(:status, reblog: reblog) }

      it 'does not re-insert status to feeds if the original status is within 40 statuses from top' do
        Redis.current.zadd("feed:type:#{account.id}", reblog.id, reblog.id)
        expect_not_to_publish
        FeedManager.instance.push_bulk('type', [account], status)
        expect(Redis.current.zscore("feed:type:#{account.id}", reblog.id)).to eq reblog.id
      end

      it 'inserts status to feeds' do
        FeedManager.instance.push_bulk('type', [account], status)
        expect(Redis.current.zscore("feed:type:#{account.id}", reblog.id)).to eq status.id
      end
    end

    context 'when status is not reblog' do
      let(:status) { Fabricate(:status, reblog: nil) }

      it 'trims timelines if they will have more than FeedManager::MAX_ITEMS' do
        members = FeedManager::MAX_ITEMS.times.map { |count| [count, count] }
        Redis.current.zadd("feed:type:#{account.id}", members)
        FeedManager.instance.push_bulk('type', [account], status)
        expect(Redis.current.zcard("feed:type:#{account.id}")).to eq FeedManager::MAX_ITEMS
      end

      it 'does not trim timelines if they will not have more than FeedManager::MAX_ITEMS' do
        members = (FeedManager::MAX_ITEMS - 1).times.map { |count| [count, count] }
        Redis.current.zadd("feed:type:#{account.id}", members)
        FeedManager.instance.push_bulk('type', [account], status)
        expect(Redis.current.zcard("feed:type:#{account.id}")).to eq FeedManager::MAX_ITEMS
      end

      it 'inserts status to feeds' do
        FeedManager.instance.push_bulk('type', [account], status)
        expect(Redis.current.zscore("feed:type:#{account.id}", status.id)).to eq status.id
      end
    end

    context 'when timeline type is home' do
      let(:status) { Fabricate(:status, reblog: nil) }

      it 'pushes status to subscribed timelines' do
        Redis.current.set("subscribed:timeline:#{account.id}", '1')
        expect_to_publish(account, status)
        FeedManager.instance.push_bulk(:home, [account], status)
      end

      it 'does not push to unsubscribed timelines' do
        expect_not_to_publish
        FeedManager.instance.push_bulk(:home, [account], status)
      end
    end

    context 'when timeline type is not home' do
      let(:status) { Fabricate(:status, reblog: nil) }

      it 'pushes status to timelines' do
        expect_to_publish(account, status)
        FeedManager.instance.push_bulk('type', [account], status)
      end
    end
  end
end
