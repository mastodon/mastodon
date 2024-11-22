# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnnualReport::CommonlyInteractedWithAccounts do
  describe '#generate' do
    subject { described_class.new(account, Time.zone.now.year) }

    context 'with an inactive account' do
      let(:account) { Fabricate :account }

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            commonly_interacted_with_accounts: be_an(Array).and(be_empty)
          )
      end
    end

    context 'with an active account' do
      let(:account) { Fabricate :account }

      let(:other_account) { Fabricate :account }
      let(:most_other_account) { Fabricate :account }

      before do
        _other = Fabricate :status

        Fabricate :status, account: account, reply: true, in_reply_to_id: Fabricate(:status, account: other_account).id
        Fabricate :status, account: account, reply: true, in_reply_to_id: Fabricate(:status, account: other_account).id

        Fabricate :status, account: account, reply: true, in_reply_to_id: Fabricate(:status, account: most_other_account).id
        Fabricate :status, account: account, reply: true, in_reply_to_id: Fabricate(:status, account: most_other_account).id
        Fabricate :status, account: account, reply: true, in_reply_to_id: Fabricate(:status, account: most_other_account).id
      end

      it 'builds a report for an account' do
        expect(subject.generate)
          .to include(
            commonly_interacted_with_accounts: eq(
              [
                { account_id: most_other_account.id.to_s, count: 3 },
                { account_id: other_account.id.to_s, count: 2 },
              ]
            )
          )
      end
    end
  end
end
