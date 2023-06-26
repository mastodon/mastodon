# frozen_string_literal: true

require 'rails_helper'

describe AccountCounters do
  let!(:account) { Fabricate(:account) }

  describe '#increment_count!' do
    it 'increments the count' do
      expect(account.followers_count).to eq 0
      account.increment_count!(:followers_count)
      expect(account.followers_count).to eq 1
    end

    it 'increments the count in multi-threaded an environment' do
      increment_by   = 15
      wait_for_start = true

      threads = Array.new(increment_by) do
        Thread.new do
          true while wait_for_start
          account.increment_count!(:statuses_count)
        end
      end

      wait_for_start = false
      threads.each(&:join)

      expect(account.statuses_count).to eq increment_by
    end
  end

  describe '#decrement_count!' do
    it 'decrements the count' do
      account.followers_count = 15
      account.save!
      expect(account.followers_count).to eq 15
      account.decrement_count!(:followers_count)
      expect(account.followers_count).to eq 14
    end

    it 'decrements the count in multi-threaded an environment' do
      decrement_by   = 10
      wait_for_start = true

      account.statuses_count = 15
      account.save!

      threads = Array.new(decrement_by) do
        Thread.new do
          true while wait_for_start
          account.decrement_count!(:statuses_count)
        end
      end

      wait_for_start = false
      threads.each(&:join)

      expect(account.statuses_count).to eq 5
    end
  end
end
