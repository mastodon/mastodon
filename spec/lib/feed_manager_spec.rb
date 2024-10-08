# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedManager do
  before do |example|
    unless example.metadata[:skip_stub]
      stub_const 'FeedManager::MAX_ITEMS', 10
      stub_const 'FeedManager::REBLOG_FALLOFF', 4
    end
  end

  it 'tracks at least as many statuses as reblogs', :skip_stub do
    expect(described_class::REBLOG_FALLOFF).to be <= described_class::MAX_ITEMS
  end

  describe '#key' do
    subject { described_class.instance.key(:home, 1) }

    it 'returns a string' do
      expect(subject).to be_a String
    end
  end

  describe '#filter?' do
    let(:alice) { Fabricate(:account, username: 'alice') }
    let(:bob)   { Fabricate(:account, username: 'bob', domain: 'example.com') }
    let(:jeff)  { Fabricate(:account, username: 'jeff') }
    let(:list) { Fabricate(:list, account: alice) }

    context 'with home feed' do
      it 'returns false for followee\'s status' do
        status = Fabricate(:status, text: 'Hello world', account: alice)
        bob.follow!(alice)
        expect(described_class.instance.filter?(:home, status, bob)).to be false
      end

      it 'returns false for reblog by followee' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reblog = Fabricate(:status, reblog: status, account: alice)
        bob.follow!(alice)
        expect(described_class.instance.filter?(:home, reblog, bob)).to be false
      end

      it 'returns true for post from account who blocked me' do
        status = Fabricate(:status, text: 'Hello, World', account: alice)
        alice.block!(bob)
        expect(described_class.instance.filter?(:home, status, bob)).to be true
      end

      it 'returns true for post from blocked account' do
        status = Fabricate(:status, text: 'Hello, World', account: alice)
        bob.block!(alice)
        expect(described_class.instance.filter?(:home, status, bob)).to be true
      end

      it 'returns true for reblog by followee of blocked account' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reblog = Fabricate(:status, reblog: status, account: alice)
        bob.follow!(alice)
        bob.block!(jeff)
        expect(described_class.instance.filter?(:home, reblog, bob)).to be true
      end

      it 'returns true for reblog by followee of muted account' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reblog = Fabricate(:status, reblog: status, account: alice)
        bob.follow!(alice)
        bob.mute!(jeff)
        expect(described_class.instance.filter?(:home, reblog, bob)).to be true
      end

      it 'returns true for reblog by followee of someone who is blocking recipient' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reblog = Fabricate(:status, reblog: status, account: alice)
        bob.follow!(alice)
        jeff.block!(bob)
        expect(described_class.instance.filter?(:home, reblog, bob)).to be true
      end

      it 'returns true for reblog from account with reblogs disabled' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reblog = Fabricate(:status, reblog: status, account: alice)
        bob.follow!(alice, reblogs: false)
        expect(described_class.instance.filter?(:home, reblog, bob)).to be true
      end

      it 'returns false for reply by followee to another followee' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
        bob.follow!(alice)
        bob.follow!(jeff)
        expect(described_class.instance.filter?(:home, reply, bob)).to be false
      end

      it 'returns false for reply by followee to recipient' do
        status = Fabricate(:status, text: 'Hello world', account: bob)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
        bob.follow!(alice)
        expect(described_class.instance.filter?(:home, reply, bob)).to be false
      end

      it 'returns false for reply by followee to self' do
        status = Fabricate(:status, text: 'Hello world', account: alice)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
        bob.follow!(alice)
        expect(described_class.instance.filter?(:home, reply, bob)).to be false
      end

      it 'returns true for reply by followee to non-followed account' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
        bob.follow!(alice)
        expect(described_class.instance.filter?(:home, reply, bob)).to be true
      end

      it 'returns true for the second reply by followee to a non-federated status' do
        reply        = Fabricate(:status, text: 'Reply 1', reply: true, account: alice)
        second_reply = Fabricate(:status, text: 'Reply 2', thread: reply, account: alice)
        bob.follow!(alice)
        expect(described_class.instance.filter?(:home, second_reply, bob)).to be true
      end

      it 'returns false for status by followee mentioning another account' do
        bob.follow!(alice)
        jeff.follow!(alice)
        status = PostStatusService.new.call(alice, text: 'Hey @jeff')
        expect(described_class.instance.filter?(:home, status, bob)).to be false
      end

      it 'returns true for status by followee mentioning blocked account' do
        bob.block!(jeff)
        bob.follow!(alice)
        status = PostStatusService.new.call(alice, text: 'Hey @jeff')
        expect(described_class.instance.filter?(:home, status, bob)).to be true
      end

      it 'returns true for reblog of a personally blocked domain' do
        alice.block_domain!('example.com')
        alice.follow!(jeff)
        status = Fabricate(:status, text: 'Hello world', account: bob)
        reblog = Fabricate(:status, reblog: status, account: jeff)
        expect(described_class.instance.filter?(:home, reblog, alice)).to be true
      end

      it 'returns true for German post when follow is set to English only' do
        alice.follow!(bob, languages: %w(en))
        status = Fabricate(:status, text: 'Hallo Welt', account: bob, language: 'de')
        expect(described_class.instance.filter?(:home, status, alice)).to be true
      end

      it 'returns false for German post when follow is set to German' do
        alice.follow!(bob, languages: %w(de))
        status = Fabricate(:status, text: 'Hallo Welt', account: bob, language: 'de')
        expect(described_class.instance.filter?(:home, status, alice)).to be false
      end

      it 'returns true for post from followee on exclusive list' do
        list.exclusive = true
        alice.follow!(bob)
        list.accounts << bob
        allow(List).to receive(:where).and_return(list)
        status = Fabricate(:status, text: 'I post a lot', account: bob)
        expect(described_class.instance.filter?(:home, status, alice)).to be true
      end

      it 'returns true for reblog from followee on exclusive list' do
        list.exclusive = true
        alice.follow!(jeff)
        list.accounts << jeff
        allow(List).to receive(:where).and_return(list)
        status = Fabricate(:status, text: 'I post a lot', account: bob)
        reblog = Fabricate(:status, reblog: status, account: jeff)
        expect(described_class.instance.filter?(:home, reblog, alice)).to be true
      end

      it 'returns false for post from followee on non-exclusive list' do
        list.exclusive = false
        alice.follow!(bob)
        list.accounts << bob
        status = Fabricate(:status, text: 'I post a lot', account: bob)
        expect(described_class.instance.filter?(:home, status, alice)).to be false
      end

      it 'returns false for reblog from followee on non-exclusive list' do
        list.exclusive = false
        alice.follow!(jeff)
        list.accounts << jeff
        status = Fabricate(:status, text: 'I post a lot', account: bob)
        reblog = Fabricate(:status, reblog: status, account: jeff)
        expect(described_class.instance.filter?(:home, reblog, alice)).to be false
      end
    end

    context 'with mentions feed' do
      it 'returns true for status that mentions blocked account' do
        bob.block!(jeff)
        status = PostStatusService.new.call(alice, text: 'Hey @jeff')
        expect(described_class.instance.filter?(:mentions, status, bob)).to be true
      end

      it 'returns true for status that replies to a blocked account' do
        status = Fabricate(:status, text: 'Hello world', account: jeff)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: alice)
        bob.block!(jeff)
        expect(described_class.instance.filter?(:mentions, reply, bob)).to be true
      end

      it 'returns false for status by limited account who recipient is not following' do
        status = Fabricate(:status, text: 'Hello world', account: alice)
        alice.silence!
        expect(described_class.instance.filter?(:mentions, status, bob)).to be false
      end

      it 'returns false for status by followed limited account' do
        status = Fabricate(:status, text: 'Hello world', account: alice)
        alice.silence!
        bob.follow!(alice)
        expect(described_class.instance.filter?(:mentions, status, bob)).to be false
      end
    end
  end

  describe '#push_to_home' do
    it 'trims timelines if they will have more than FeedManager::MAX_ITEMS' do
      account = Fabricate(:account)
      status = Fabricate(:status)
      members = Array.new(described_class::MAX_ITEMS) { |count| [count, count] }
      redis.zadd("feed:home:#{account.id}", members)

      described_class.instance.push_to_home(account, status)

      expect(redis.zcard("feed:home:#{account.id}")).to eq described_class::MAX_ITEMS
    end

    context 'with reblogs' do
      it 'saves reblogs of unseen statuses' do
        account = Fabricate(:account)
        reblogged = Fabricate(:status)
        reblog = Fabricate(:status, reblog: reblogged)

        expect(described_class.instance.push_to_home(account, reblog)).to be true
      end

      it 'does not save a new reblog of a recent status' do
        account = Fabricate(:account)
        reblogged = Fabricate(:status)
        reblog = Fabricate(:status, reblog: reblogged)

        described_class.instance.push_to_home(account, reblogged)

        expect(described_class.instance.push_to_home(account, reblog)).to be false
      end

      it 'saves a new reblog of an old status' do
        account = Fabricate(:account)
        reblogged = Fabricate(:status)
        reblog = Fabricate(:status, reblog: reblogged)

        described_class.instance.push_to_home(account, reblogged)

        # Fill the feed with intervening statuses
        described_class::REBLOG_FALLOFF.times do
          described_class.instance.push_to_home(account, Fabricate(:status))
        end

        expect(described_class.instance.push_to_home(account, reblog)).to be true
      end

      it 'does not save a new reblog of a recently-reblogged status' do
        account = Fabricate(:account)
        reblogged = Fabricate(:status)
        reblogs = Array.new(2) { Fabricate(:status, reblog: reblogged) }

        # The first reblog will be accepted
        described_class.instance.push_to_home(account, reblogs.first)

        # The second reblog should be ignored
        expect(described_class.instance.push_to_home(account, reblogs.last)).to be false
      end

      it 'saves a new reblog of a recently-reblogged status when previous reblog has been deleted' do
        account = Fabricate(:account)
        reblogged = Fabricate(:status)
        old_reblog = Fabricate(:status, reblog: reblogged)

        # The first reblog should be accepted
        expect(described_class.instance.push_to_home(account, old_reblog)).to be true

        # The first reblog should be successfully removed
        expect(described_class.instance.unpush_from_home(account, old_reblog)).to be true

        reblog = Fabricate(:status, reblog: reblogged)

        # The second reblog should be accepted
        expect(described_class.instance.push_to_home(account, reblog)).to be true
      end

      it 'does not save a new reblog of a multiply-reblogged-then-unreblogged status' do
        account   = Fabricate(:account)
        reblogged = Fabricate(:status)
        reblogs = Array.new(3) { Fabricate(:status, reblog: reblogged) }

        # Accept the reblogs
        described_class.instance.push_to_home(account, reblogs[0])
        described_class.instance.push_to_home(account, reblogs[1])

        # Unreblog the first one
        described_class.instance.unpush_from_home(account, reblogs[0])

        # The last reblog should still be ignored
        expect(described_class.instance.push_to_home(account, reblogs.last)).to be false
      end

      it 'saves a new reblog of a long-ago-reblogged status' do
        account = Fabricate(:account)
        reblogged = Fabricate(:status)
        reblogs = Array.new(2) { Fabricate(:status, reblog: reblogged) }

        # The first reblog will be accepted
        described_class.instance.push_to_home(account, reblogs.first)

        # Fill the feed with intervening statuses
        described_class::REBLOG_FALLOFF.times do
          described_class.instance.push_to_home(account, Fabricate(:status))
        end

        # The second reblog should also be accepted
        expect(described_class.instance.push_to_home(account, reblogs.last)).to be true
      end
    end

    it "does not push when the given status's reblog is already inserted" do
      account = Fabricate(:account)
      reblog = Fabricate(:status)
      status = Fabricate(:status, reblog: reblog)
      described_class.instance.push_to_home(account, status)

      expect(described_class.instance.push_to_home(account, reblog)).to be false
    end
  end

  describe '#push_to_list' do
    let(:owner) { Fabricate(:account, username: 'owner') }
    let(:alice) { Fabricate(:account, username: 'alice') }
    let(:bob)   { Fabricate(:account, username: 'bob') }
    let(:eve)   { Fabricate(:account, username: 'eve') }
    let(:list)  { Fabricate(:list, account: owner) }

    before do
      owner.follow!(alice)
      owner.follow!(bob)
      owner.follow!(eve)

      list.accounts << alice
      list.accounts << bob
    end

    it "does not push when the given status's reblog is already inserted" do
      reblog = Fabricate(:status)
      status = Fabricate(:status, reblog: reblog)
      described_class.instance.push_to_list(list, status)

      expect(described_class.instance.push_to_list(list, reblog)).to be false
    end

    context 'when replies policy is set to no replies' do
      before do
        list.replies_policy = :none
      end

      it 'pushes statuses that are not replies' do
        status = Fabricate(:status, text: 'Hello world', account: bob)
        expect(described_class.instance.push_to_list(list, status)).to be true
      end

      it 'pushes statuses that are replies to list owner' do
        status = Fabricate(:status, text: 'Hello world', account: owner)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: bob)
        expect(described_class.instance.push_to_list(list, reply)).to be true
      end

      it 'does not push replies to another member of the list' do
        status = Fabricate(:status, text: 'Hello world', account: alice)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: bob)
        expect(described_class.instance.push_to_list(list, reply)).to be false
      end
    end

    context 'when replies policy is set to list-only replies' do
      before do
        list.replies_policy = :list
      end

      it 'pushes statuses that are not replies' do
        status = Fabricate(:status, text: 'Hello world', account: bob)
        expect(described_class.instance.push_to_list(list, status)).to be true
      end

      it 'pushes statuses that are replies to list owner' do
        status = Fabricate(:status, text: 'Hello world', account: owner)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: bob)
        expect(described_class.instance.push_to_list(list, reply)).to be true
      end

      it 'pushes replies to another member of the list' do
        status = Fabricate(:status, text: 'Hello world', account: alice)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: bob)
        expect(described_class.instance.push_to_list(list, reply)).to be true
      end

      it 'does not push replies to someone not a member of the list' do
        status = Fabricate(:status, text: 'Hello world', account: eve)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: bob)
        expect(described_class.instance.push_to_list(list, reply)).to be false
      end
    end

    context 'when replies policy is set to any reply' do
      before do
        list.replies_policy = :followed
      end

      it 'pushes statuses that are not replies' do
        status = Fabricate(:status, text: 'Hello world', account: bob)
        expect(described_class.instance.push_to_list(list, status)).to be true
      end

      it 'pushes statuses that are replies to list owner' do
        status = Fabricate(:status, text: 'Hello world', account: owner)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: bob)
        expect(described_class.instance.push_to_list(list, reply)).to be true
      end

      it 'pushes replies to another member of the list' do
        status = Fabricate(:status, text: 'Hello world', account: alice)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: bob)
        expect(described_class.instance.push_to_list(list, reply)).to be true
      end

      it 'pushes replies to someone not a member of the list' do
        status = Fabricate(:status, text: 'Hello world', account: eve)
        reply  = Fabricate(:status, text: 'Nay', thread: status, account: bob)
        expect(described_class.instance.push_to_list(list, reply)).to be true
      end
    end
  end

  describe '#merge_into_home' do
    it "does not push source account's statuses whose reblogs are already inserted" do
      account = Fabricate(:account, id: 0)
      reblog = Fabricate(:status)
      status = Fabricate(:status, reblog: reblog)
      described_class.instance.push_to_home(account, status)

      described_class.instance.merge_into_home(account, reblog.account)

      expect(redis.zscore('feed:home:0', reblog.id)).to be_nil
    end
  end

  describe '#unpush_from_home' do
    let(:receiver) { Fabricate(:account) }

    it 'leaves a reblogged status if original was on feed' do
      reblogged = Fabricate(:status)
      status    = Fabricate(:status, reblog: reblogged)

      described_class.instance.push_to_home(receiver, reblogged)
      described_class::REBLOG_FALLOFF.times { described_class.instance.push_to_home(receiver, Fabricate(:status)) }
      described_class.instance.push_to_home(receiver, status)

      # The reblogging status should show up under normal conditions.
      expect(redis.zrange("feed:home:#{receiver.id}", 0, -1)).to include(status.id.to_s)

      described_class.instance.unpush_from_home(receiver, status)

      # Restore original status
      expect(redis.zrange("feed:home:#{receiver.id}", 0, -1)).to_not include(status.id.to_s)
      expect(redis.zrange("feed:home:#{receiver.id}", 0, -1)).to include(reblogged.id.to_s)
    end

    it 'removes a reblogged status if it was only reblogged once' do
      reblogged = Fabricate(:status)
      status    = Fabricate(:status, reblog: reblogged)

      described_class.instance.push_to_home(receiver, status)

      # The reblogging status should show up under normal conditions.
      expect(redis.zrange("feed:home:#{receiver.id}", 0, -1)).to eq [status.id.to_s]

      described_class.instance.unpush_from_home(receiver, status)

      expect(redis.zrange("feed:home:#{receiver.id}", 0, -1)).to be_empty
    end

    it 'leaves a multiply-reblogged status if another reblog was in feed' do
      reblogged = Fabricate(:status)
      reblogs   = Array.new(3) { Fabricate(:status, reblog: reblogged) }

      reblogs.each do |reblog|
        described_class.instance.push_to_home(receiver, reblog)
      end

      # The reblogging status should show up under normal conditions.
      expect(redis.zrange("feed:home:#{receiver.id}", 0, -1)).to eq [reblogs.first.id.to_s]

      reblogs[0...-1].each do |reblog|
        described_class.instance.unpush_from_home(receiver, reblog)
      end

      expect(redis.zrange("feed:home:#{receiver.id}", 0, -1)).to eq [reblogs.last.id.to_s]
    end

    it 'sends push updates' do
      status = Fabricate(:status)

      described_class.instance.push_to_home(receiver, status)

      allow(redis).to receive_messages(publish: nil)
      described_class.instance.unpush_from_home(receiver, status)

      deletion = Oj.dump(event: :delete, payload: status.id.to_s)
      expect(redis).to have_received(:publish).with("timeline:#{receiver.id}", deletion)
    end
  end

  describe '#unmerge_tag_from_home' do
    let(:receiver) { Fabricate(:account) }
    let(:tag) { Fabricate(:tag) }

    it 'leaves a tagged status' do
      status = Fabricate(:status)
      status.tags << tag
      described_class.instance.push_to_home(receiver, status)

      described_class.instance.unmerge_tag_from_home(tag, receiver)

      expect(redis.zrange("feed:home:#{receiver.id}", 0, -1)).to_not include(status.id.to_s)
    end

    it 'remains a tagged status written by receiver\'s followee' do
      followee = Fabricate(:account)
      receiver.follow!(followee)

      status = Fabricate(:status, account: followee)
      status.tags << tag
      described_class.instance.push_to_home(receiver, status)

      described_class.instance.unmerge_tag_from_home(tag, receiver)

      expect(redis.zrange("feed:home:#{receiver.id}", 0, -1)).to include(status.id.to_s)
    end

    it 'remains a tagged status written by receiver' do
      status = Fabricate(:status, account: receiver)
      status.tags << tag
      described_class.instance.push_to_home(receiver, status)

      described_class.instance.unmerge_tag_from_home(tag, receiver)

      expect(redis.zrange("feed:home:#{receiver.id}", 0, -1)).to include(status.id.to_s)
    end
  end

  describe '#clear_from_home' do
    let(:account) { Fabricate(:account) }
    let(:followed_account) { Fabricate(:account) }
    let(:target_account) { Fabricate(:account) }
    let(:status_from_followed_account_first) { Fabricate(:status, account: followed_account) }
    let(:status_from_target_account) { Fabricate(:status, account: target_account) }
    let(:status_from_followed_account_mentions_target_account) { Fabricate(:status, account: followed_account, mentions: [Fabricate(:mention, account: target_account)]) }
    let(:status_mentions_target_account) { Fabricate(:status, mentions: [Fabricate(:mention, account: target_account)]) }
    let(:status_from_followed_account_reblogs_status_mentions_target_account) { Fabricate(:status, account: followed_account, reblog: status_mentions_target_account) }
    let(:status_from_followed_account_reblogs_status_from_target_account) { Fabricate(:status, account: followed_account, reblog: status_from_target_account) }
    let(:status_from_followed_account_next) { Fabricate(:status, account: followed_account) }

    before do
      [
        status_from_followed_account_first,
        status_from_followed_account_mentions_target_account,
        status_from_followed_account_reblogs_status_mentions_target_account,
        status_from_followed_account_reblogs_status_from_target_account,
        status_from_followed_account_next,
      ].each do |status|
        redis.zadd("feed:home:#{account.id}", status.id, status.id)
      end
    end

    it 'correctly cleans the home timeline' do
      described_class.instance.clear_from_home(account, target_account)

      expect(redis.zrange("feed:home:#{account.id}", 0, -1)).to eq [status_from_followed_account_first.id.to_s, status_from_followed_account_next.id.to_s]
    end
  end
end
