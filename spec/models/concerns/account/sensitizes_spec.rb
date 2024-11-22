# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Sensitizes do
  describe 'Scopes' do
    describe '.sensitized' do
      let(:sensitized_account) { Fabricate :account, sensitized_at: 2.days.ago }

      before { Fabricate :account, sensitized_at: nil }

      it 'returns an array of accounts who are sensitized' do
        expect(Account.sensitized)
          .to contain_exactly(sensitized_account)
      end
    end
  end
end
