# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::AccountBatch do
  let(:account_batch) { described_class.new }

  describe '#save' do
    subject           { account_batch.save }

    let(:account)     { Fabricate(:user, role: UserRole.find_by(name: 'Admin')).account }
    let(:account_ids) { [] }
    let(:query)       { Account.none }

    before do
      account_batch.assign_attributes(
        action: action,
        current_account: account,
        account_ids: account_ids,
        query: query,
        select_all_matching: select_all_matching
      )
    end

    context 'when action is "suspend"' do
      let(:action) { 'suspend' }

      let(:target_account)  { Fabricate(:account) }
      let(:target_account2) { Fabricate(:account) }

      before do
        Fabricate(:report, target_account: target_account)
        Fabricate(:report, target_account: target_account2)
      end

      context 'when accounts are passed as account_ids' do
        let(:select_all_matching) { '0' }
        let(:account_ids)         { [target_account.id, target_account2.id] }

        it 'suspends the expected users' do
          expect { subject }.to change { [target_account.reload.suspended?, target_account2.reload.suspended?] }.from([false, false]).to([true, true])
        end

        it 'closes open reports targeting the suspended users' do
          expect { subject }.to change { Report.unresolved.where(target_account: [target_account, target_account2]).count }.from(2).to(0)
        end
      end

      context 'when accounts are passed as a query' do
        let(:select_all_matching) { '1' }
        let(:query)               { Account.where(id: [target_account.id, target_account2.id]) }

        it 'suspends the expected users' do
          expect { subject }.to change { [target_account.reload.suspended?, target_account2.reload.suspended?] }.from([false, false]).to([true, true])
        end

        it 'closes open reports targeting the suspended users' do
          expect { subject }.to change { Report.unresolved.where(target_account: [target_account, target_account2]).count }.from(2).to(0)
        end
      end
    end
  end
end
