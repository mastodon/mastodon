# frozen_string_literal: true

require 'rails_helper'

describe AccountStatusesCleanupService, type: :service do
  let(:account)           { Fabricate(:account, username: 'alice', domain: nil) }
  let(:account_policy)    { Fabricate(:account_statuses_cleanup_policy, account: account) }
  let!(:unrelated_status) { Fabricate(:status, created_at: 3.years.ago) }

  describe '#call' do
    context 'when the account has not posted anything' do
      it 'returns 0 deleted toots' do
        expect(subject.call(account_policy)).to eq 0
      end
    end

    context 'when the account has posted several old statuses' do
      let!(:very_old_status)    { Fabricate(:status, created_at: 3.years.ago, account: account) }
      let!(:old_status)         { Fabricate(:status, created_at: 1.year.ago, account: account) }
      let!(:another_old_status) { Fabricate(:status, created_at: 1.year.ago, account: account) }
      let!(:recent_status)      { Fabricate(:status, created_at: 1.day.ago, account: account) }

      context 'when given a budget of 1' do
        it 'reports 1 deleted toot' do
          expect(subject.call(account_policy, 1)).to eq 1
        end
      end

      context 'when given a normal budget of 10' do
        it 'reports 3 deleted statuses' do
          expect(subject.call(account_policy, 10)).to eq 3
        end

        it 'records the last deleted id' do
          subject.call(account_policy, 10)
          expect(account_policy.last_inspected).to eq [old_status.id, another_old_status.id].max
        end

        it 'actually deletes the statuses' do
          subject.call(account_policy, 10)
          expect(Status.find_by(id: [very_old_status.id, old_status.id, another_old_status.id])).to be_nil
        end
      end

      context 'when called repeatedly with a budget of 2' do
        it 'reports 2 then 1 deleted statuses' do
          expect(subject.call(account_policy, 2)).to eq 2
          expect(subject.call(account_policy, 2)).to eq 1
        end

        it 'actually deletes the statuses in the expected order' do
          subject.call(account_policy, 2)
          expect(Status.find_by(id: very_old_status.id)).to be_nil
          subject.call(account_policy, 2)
          expect(Status.find_by(id: [very_old_status.id, old_status.id, another_old_status.id])).to be_nil
        end
      end

      context 'when a self-faved toot is unfaved' do
        let!(:self_faved) { Fabricate(:status, created_at: 6.months.ago, account: account) }
        let!(:favourite)  { Fabricate(:favourite, account: account, status: self_faved) }

        it 'deletes it once unfaved' do
          expect(subject.call(account_policy, 20)).to eq 3
          expect(Status.find_by(id: self_faved.id)).to_not be_nil
          expect(subject.call(account_policy, 20)).to eq 0
          favourite.destroy!
          expect(subject.call(account_policy, 20)).to eq 1
          expect(Status.find_by(id: self_faved.id)).to be_nil
        end
      end

      context 'when there are more un-deletable old toots than the early search cutoff' do
        before do
          stub_const 'AccountStatusesCleanupPolicy::EARLY_SEARCH_CUTOFF', 5
          # Old statuses that should be cut-off
          10.times do
            Fabricate(:status, created_at: 4.years.ago, visibility: :direct, account: account)
          end
          # New statuses that prevent cut-off id to reach the last status
          10.times do
            Fabricate(:status, created_at: 4.seconds.ago, visibility: :direct, account: account)
          end
        end

        it 'reports 0 deleted statuses then 0 then 3 then 0 again' do
          expect(subject.call(account_policy, 10)).to eq 0
          expect(subject.call(account_policy, 10)).to eq 0
          expect(subject.call(account_policy, 10)).to eq 3
          expect(subject.call(account_policy, 10)).to eq 0
        end

        it 'never causes the recorded id to get higher than oldest deletable toot' do
          subject.call(account_policy, 10)
          subject.call(account_policy, 10)
          subject.call(account_policy, 10)
          subject.call(account_policy, 10)
          expect(account_policy.last_inspected).to be < Mastodon::Snowflake.id_at(account_policy.min_status_age.seconds.ago, with_random: false)
        end
      end
    end
  end
end
