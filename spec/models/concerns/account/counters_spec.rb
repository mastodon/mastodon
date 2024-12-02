# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Counters do
  let!(:account) { Fabricate(:account) }

  describe '#increment_count!' do
    let(:increment_by) { 15 }

    it 'increments the count' do
      expect(account.followers_count).to eq 0
      account.increment_count!(:followers_count)
      expect(account.followers_count).to eq 1
    end

    it 'increments the count in multi-threaded an environment' do
      multi_threaded_execution(increment_by) do
        account.increment_count!(:statuses_count)
      end

      expect(account.statuses_count).to eq increment_by
    end
  end

  describe '#decrement_count!' do
    let(:decrement_by) { 10 }

    it 'decrements the count' do
      account.followers_count = 15
      account.save!
      expect(account.followers_count).to eq 15
      account.decrement_count!(:followers_count)
      expect(account.followers_count).to eq 14
    end

    it 'decrements the count in multi-threaded an environment' do
      account.statuses_count = 15
      account.save!

      multi_threaded_execution(decrement_by) do
        account.decrement_count!(:statuses_count)
      end

      expect(account.statuses_count).to eq 5
    end

    it 'preserves last_status_at when decrementing statuses_count' do
      account_stat = Fabricate(
        :account_stat,
        account: account,
        last_status_at: 3.days.ago,
        statuses_count: 10
      )

      expect { account.decrement_count!(:statuses_count) }
        .to change(account_stat.reload, :statuses_count).by(-1)
        .and not_change(account_stat.reload, :last_status_at)
    end
  end
end
