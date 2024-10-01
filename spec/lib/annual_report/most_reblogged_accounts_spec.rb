# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnualReport::MostRebloggedAccounts do
  describe '#generate' do
    subject { described_class.new(account, Time.zone.now.year) }

    context 'with an inactive account' do
      let(:account) { Fabricate :account }

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            most_reblogged_accounts: be_an(Array).and(be_empty)
          )
      end
    end

    context 'with an active account' do
      let(:account) { Fabricate :account }

      let(:other_account) { Fabricate :account }

      before do
        _other = Fabricate :status
        Fabricate :status, account: account, reblog: Fabricate(:status, account: other_account)
        Fabricate :status, account: account, reblog: Fabricate(:status, account: other_account)
      end

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            most_reblogged_accounts: contain_exactly(
              include(account_id: other_account.id, count: 2)
            )
          )
      end
    end
  end
end
