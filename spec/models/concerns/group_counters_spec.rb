require 'rails_helper'

describe GroupCounters do
  let!(:group) { Fabricate(:group) }

  describe '#increment_count!' do
    it 'increments the count' do
      expect(group.members_count).to eq 0
      group.increment_count!(:members_count)
      expect(group.members_count).to eq 1
    end

    it 'increments the count in multi-threaded an environment' do
      increment_by   = 15
      wait_for_start = true

      threads = Array.new(increment_by) do
        Thread.new do
          true while wait_for_start
          group.increment_count!(:statuses_count)
        end
      end

      wait_for_start = false
      threads.each(&:join)

      expect(group.statuses_count).to eq increment_by
    end
  end

  describe '#decrement_count!' do
    it 'decrements the count' do
      group.members_count = 15
      group.save!
      expect(group.members_count).to eq 15
      group.decrement_count!(:members_count)
      expect(group.members_count).to eq 14
    end

    it 'decrements the count in multi-threaded an environment' do
      decrement_by   = 10
      wait_for_start = true

      group.statuses_count = 15
      group.save!

      threads = Array.new(decrement_by) do
        Thread.new do
          true while wait_for_start
          group.decrement_count!(:statuses_count)
        end
      end

      wait_for_start = false
      threads.each(&:join)

      expect(group.statuses_count).to eq 5
    end
  end
end
