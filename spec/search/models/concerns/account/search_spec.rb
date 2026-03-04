# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Search do
  describe 'Callbacks for discoverable changes' do
    let(:results) { AccountsIndex.filter(term: { username: account.username }) }

    context 'with a non-discoverable account' do
      let(:account) { Fabricate :account, discoverable: false }

      context 'when looking for the account' do
        it 'is missing from the AccountsIndex' do
          expect(results.count)
            .to eq(1)
          expect(results.first.text)
            .to be_nil
        end
      end

      context 'when the account becomes discoverable' do
        before { account.update! discoverable: true }

        it 'is present in the AccountsIndex' do
          expect(results.count)
            .to eq(1)
          expect(results.first.text)
            .to eq(account.note)
        end
      end
    end

    describe 'with a discoverable account' do
      let(:account) { Fabricate :account, discoverable: true }

      context 'when looking for the account' do
        it 'is present in the AccountsIndex' do
          expect(results.count)
            .to eq(1)
          expect(results.first.text)
            .to eq(account.note)
        end
      end

      context 'when the account becomes non-discoverable' do
        before { account.update! discoverable: false }

        it 'is missing from the AccountsIndex' do
          expect(results.count)
            .to eq(1)
          expect(results.first.text)
            .to be_nil
        end
      end
    end
  end
end
