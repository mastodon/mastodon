# frozen_string_literal: true

require 'rails_helper'

describe RelationshipFilter do
  let(:account) { Fabricate(:account) }

  describe '#results' do
    let(:account_of_7_months) { Fabricate(:account_stat, statuses_count: 1, last_status_at: 7.months.ago).account }
    let(:account_of_1_day)    { Fabricate(:account_stat, statuses_count: 1, last_status_at: 1.day.ago).account }
    let(:account_of_3_days)   { Fabricate(:account_stat, statuses_count: 1, last_status_at: 3.days.ago).account }
    let(:silent_account)      { Fabricate(:account_stat, statuses_count: 0, last_status_at: nil).account }

    before do
      account.follow!(account_of_7_months)
      account.follow!(account_of_1_day)
      account.follow!(account_of_3_days)
      account.follow!(silent_account)
    end

    context 'when ordering by last activity' do
      context 'when not filtering' do
        subject do
          described_class.new(account, 'order' => 'active').results
        end

        it 'returns followings ordered by last activity' do
          expect(subject).to eq [account_of_1_day, account_of_3_days, account_of_7_months, silent_account]
        end
      end

      context 'when filtering for dormant accounts' do
        subject do
          described_class.new(account, 'order' => 'active', 'activity' => 'dormant').results
        end

        it 'returns dormant followings ordered by last activity' do
          expect(subject).to eq [account_of_7_months, silent_account]
        end
      end
    end

    context 'when ordering by account creation' do
      context 'when not filtering' do
        subject do
          described_class.new(account, 'order' => 'recent').results
        end

        it 'returns followings ordered by last account creation' do
          expect(subject).to eq [silent_account, account_of_3_days, account_of_1_day, account_of_7_months]
        end
      end

      context 'when filtering for dormant accounts' do
        subject do
          described_class.new(account, 'order' => 'recent', 'activity' => 'dormant').results
        end

        it 'returns dormant followings ordered by last activity' do
          expect(subject).to eq [silent_account, account_of_7_months]
        end
      end
    end
  end
end
