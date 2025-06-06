# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeFeed do
  subject { described_class.new(account) }

  let(:account) { Fabricate(:account) }

  describe '#get' do
    before do
      Fabricate(:status, account: account, id: 1)
      Fabricate(:status, account: account, id: 2)
      Fabricate(:status, account: account, id: 3)
      Fabricate(:status, account: account, id: 10)
    end

    context 'when feed is generated' do
      before do
        redis.zadd(
          FeedManager.instance.key(:home, account.id),
          [[4, 4], [3, 3], [2, 2], [1, 1]]
        )
      end

      it 'gets statuses with ids in the range from redis' do
        results = subject.get(3)

        expect(results.map(&:id)).to eq [3, 2]
      end
    end

    context 'when feed is being generated' do
      before do
        redis.hset("account:#{account.id}:regeneration", { 'status' => 'running' })
      end

      it 'returns nothing' do
        results = subject.get(3)

        expect(results.map(&:id)).to eq []
      end
    end
  end

  describe '#regenerating?' do
    context 'when an old-style string key is still in use' do
      it 'upgrades the key to a hash' do
        redis.set("account:#{account.id}:regeneration", true)

        expect(subject.regenerating?).to be true

        expect(redis.type("account:#{account.id}:regeneration")).to eq 'hash'
      end
    end

    context 'when feed is being generated' do
      before do
        redis.hset("account:#{account.id}:regeneration", { 'status' => 'running' })
      end

      it 'returns `true`' do
        expect(subject.regenerating?).to be true
      end
    end

    context 'when feed is not being generated' do
      context 'when the job is marked as finished' do
        before do
          redis.hset("account:#{account.id}:regeneration", { 'status' => 'finished' })
        end

        it 'returns `false`' do
          expect(subject.regenerating?).to be false
        end
      end

      context 'when the job key is missing' do
        it 'returns `false`' do
          expect(subject.regenerating?).to be false
        end
      end
    end
  end

  describe '#regeneration_in_progress!' do
    context 'when an old-style string key is still in use' do
      it 'upgrades the key to a hash' do
        redis.set("account:#{account.id}:regeneration", true)

        subject.regeneration_in_progress!

        expect(redis.type("account:#{account.id}:regeneration")).to eq 'hash'
      end
    end

    it 'sets the corresponding key in redis' do
      expect(redis.exists?("account:#{account.id}:regeneration")).to be false

      subject.regeneration_in_progress!

      expect(redis.exists?("account:#{account.id}:regeneration")).to be true
    end
  end

  describe '#regeneration_finished!' do
    context 'when an old-style string key is still in use' do
      it 'upgrades the key to a hash' do
        redis.set("account:#{account.id}:regeneration", true)

        subject.regeneration_finished!

        expect(redis.type("account:#{account.id}:regeneration")).to eq 'hash'
      end
    end

    it "sets the corresponding key's status to 'finished'" do
      redis.hset("account:#{account.id}:regeneration", { 'status' => 'running' })

      subject.regeneration_finished!

      expect(redis.hget("account:#{account.id}:regeneration", 'status')).to eq 'finished'
    end
  end
end
