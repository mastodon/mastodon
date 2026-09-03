# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Form::AccountBatch do
  let(:account_batch) { described_class.new }

  describe '#save' do
    subject           { account_batch.save }

    let(:account)     { Fabricate(:admin_user).account }
    let(:account_ids) { [] }
    let(:query)       { Account.none }
    let(:select_all_matching) { false }

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

        it 'suspends the expected users and closes open reports' do
          expect { subject }
            .to change_account_suspensions
            .and change_open_reports_for_accounts
        end
      end

      context 'when accounts are passed as a query' do
        let(:select_all_matching) { '1' }
        let(:query)               { Account.where(id: [target_account.id, target_account2.id]) }

        it 'suspends the expected users and closes open reports' do
          expect { subject }
            .to change_account_suspensions
            .and change_open_reports_for_accounts
        end
      end

      private

      def change_account_suspensions
        change { relevant_account_suspension_statuses }
          .from([false, false])
          .to([true, true])
      end

      def change_open_reports_for_accounts
        change(relevant_account_unresolved_reports, :count)
          .from(2)
          .to(0)
      end

      def relevant_account_unresolved_reports
        Report.unresolved.where(target_account: [target_account, target_account2])
      end

      def relevant_account_suspension_statuses
        [target_account.reload, target_account2.reload].map(&:suspended?)
      end
    end

    context 'when action is "approve"' do
      let(:action) { 'approve' }
      let(:account_ids) { [unapproved_user_account.id] }
      let(:unapproved_user_account) { Fabricate :account }

      before { unapproved_user_account.user.update!(approved: false) }

      it 'approves the user of the supplied accounts' do
        expect { subject }
          .to change { unapproved_user_account.reload.user.approved? }.to(true)
      end
    end

    context 'when action is "reject"' do
      let(:action) { 'reject' }
      let(:account_ids) { [reject_user_account.id] }
      let(:reject_user_account) { Fabricate :account }

      before { reject_user_account.user.update!(approved: false) }

      it 'rejects the user of the supplied accounts' do
        expect { subject }
          .to change { reject_user_account.reload.suspended? }.to(true)
      end
    end

    context 'when action is "unknown"' do
      let(:action) { 'unknown' }

      it { is_expected.to be_nil }
    end
  end
end
