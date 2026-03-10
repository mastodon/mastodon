# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Search do
  describe 'Callbacks for discoverable changes' do
    let(:results) { AccountsIndex.filter(term: { username: account.username }) }

    context 'with a non-discoverable account' do
      let(:account) { Fabricate :account, discoverable: false, note: 'Account note' }

      context 'when looking for the non discoverable account' do
        it 'is missing account bio in the AccountsIndex' do
          expect(results.count)
            .to eq(1)
          expect(results.first.text)
            .to be_nil
        end
      end

      context 'when the account becomes discoverable' do
        it 'has an account bio in the AccountsIndex' do
          expect { account.update! discoverable: true }
            .to change { results.first.text }.from(be_blank).to(account.note)
            .and not_change(results, :count).from(1)
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
        it 'is missing from the AccountsIndex' do
          expect { account.update! discoverable: false }
            .to change { results.first.text }.from(account.note).to(be_blank)
            .and not_change(results, :count).from(1)
        end
      end
    end
  end
end
