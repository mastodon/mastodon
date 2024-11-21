# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Silences do
  describe 'Scopes' do
    describe '.silenced' do
      let(:silenced_account) { Fabricate :account, silenced: true }

      before { Fabricate :account, silenced: false }

      it 'returns an array of accounts who are silenced' do
        expect(Account.silenced)
          .to contain_exactly(silenced_account)
      end
    end
  end
end
