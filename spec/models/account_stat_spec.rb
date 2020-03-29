require 'rails_helper'

RSpec.describe AccountStat, type: :model do
  describe '#increment_count!' do
    it 'increments the count' do
      account_stat = AccountStat.create(account: Fabricate(:account))
      expect(account_stat.followers_count).to eq 0
      account_stat.increment_count!(:followers_count)
      expect(account_stat.followers_count).to eq 1
    end

    it 'increments the count in multi-threaded an environment' do
      account_stat   = AccountStat.create(account: Fabricate(:account), statuses_count: 0)
      increment_by   = 15
      wait_for_start = true

      threads = Array.new(increment_by) do
        Thread.new do
          true while wait_for_start
          AccountStat.find(account_stat.id).increment_count!(:statuses_count)
        end
      end

      wait_for_start = false
      threads.each(&:join)

      expect(account_stat.reload.statuses_count).to eq increment_by
    end
  end

  describe '#decrement_count!' do
    it 'decrements the count' do
      account_stat = AccountStat.create(account: Fabricate(:account), followers_count: 15)
      expect(account_stat.followers_count).to eq 15
      account_stat.decrement_count!(:followers_count)
      expect(account_stat.followers_count).to eq 14
    end

    it 'decrements the count in multi-threaded an environment' do
      account_stat   = AccountStat.create(account: Fabricate(:account), statuses_count: 15)
      decrement_by   = 10
      wait_for_start = true

      threads = Array.new(decrement_by) do
        Thread.new do
          true while wait_for_start
          AccountStat.find(account_stat.id).decrement_count!(:statuses_count)
        end
      end

      wait_for_start = false
      threads.each(&:join)

      expect(account_stat.reload.statuses_count).to eq 5
    end
  end
end
