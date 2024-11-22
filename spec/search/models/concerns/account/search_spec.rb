# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Search do
  describe 'a non-discoverable account becoming discoverable' do
    let(:account) { Account.find_by(username: 'search_test_account_1') }

    context 'when picking a non-discoverable account' do
      it 'its bio is not in the AccountsIndex' do
        results = AccountsIndex.filter(term: { username: account.username })
        expect(results.count).to eq(1)
        expect(results.first.text).to be_nil
      end
    end

    context 'when the non-discoverable account becomes discoverable' do
      it 'its bio is added to the AccountsIndex' do
        account.discoverable = true
        account.save!

        results = AccountsIndex.filter(term: { username: account.username })
        expect(results.count).to eq(1)
        expect(results.first.text).to eq(account.note)
      end
    end
  end

  describe 'a discoverable account becoming non-discoverable' do
    let(:account) { Account.find_by(username: 'search_test_account_0') }

    context 'when picking an discoverable account' do
      it 'has its bio in the AccountsIndex' do
        results = AccountsIndex.filter(term: { username: account.username })
        expect(results.count).to eq(1)
        expect(results.first.text).to eq(account.note)
      end
    end

    context 'when the discoverable account becomes non-discoverable' do
      it 'its bio is removed from the AccountsIndex' do
        account.discoverable = false
        account.save!

        results = AccountsIndex.filter(term: { username: account.username })
        expect(results.count).to eq(1)
        expect(results.first.text).to be_nil
      end
    end
  end
end
