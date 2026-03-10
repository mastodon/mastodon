# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::StatusesSearch, :inline_jobs do
  describe 'Callbacks for indexable changes' do
    let(:account) { Fabricate :account, indexable: }
    let(:public_statuses_results) { PublicStatusesIndex.filter(term: { account_id: account.id }) }
    let(:statuses_results) { StatusesIndex.filter(term: { account_id: account.id }) }

    before do
      Fabricate :status, account:, visibility: :private
      Fabricate :status, account:, visibility: :public
    end

    context 'with a non-indexable account' do
      let(:indexable) { false }

      context 'when looking for statuses from the account' do
        it 'does not have public index statuses' do
          expect(public_statuses_results.count)
            .to eq(0)
          expect(statuses_results.count)
            .to eq(account.statuses.count)
        end
      end

      context 'when the non-indexable account becomes indexable' do
        it 'does have public index statuses' do
          expect { account.update! indexable: true }
            .to change(public_statuses_results, :count).to(account.statuses.public_visibility.count)
            .and not_change(statuses_results, :count).from(account.statuses.count)
        end
      end
    end

    describe 'with an indexable account' do
      let(:indexable) { true }

      context 'when picking an indexable account' do
        it 'does have public index statuses' do
          expect(public_statuses_results.count)
            .to eq(account.statuses.public_visibility.count)
          expect(statuses_results.count)
            .to eq(account.statuses.count)
        end
      end

      context 'when the indexable account becomes non-indexable' do
        it 'does not have public index statuses' do
          expect { account.update! indexable: false }
            .to change(public_statuses_results, :count).to(0)
            .and not_change(statuses_results, :count).from(account.statuses.count)
        end
      end
    end
  end
end
