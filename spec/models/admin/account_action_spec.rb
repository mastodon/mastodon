# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AccountAction do
  let(:account_action) { described_class.new }

  describe '#save!' do
    subject              { account_action.save! }

    let(:account)        { Fabricate(:admin_user).account }
    let(:target_account) { Fabricate(:account) }
    let(:type)           { 'disable' }

    before do
      account_action.assign_attributes(
        type: type,
        current_account: account,
        target_account: target_account
      )
    end

    context 'when type is "disable"' do
      let(:type) { 'disable' }

      it 'disable user' do
        subject
        expect(target_account.user).to be_disabled
      end
    end

    context 'when type is "silence"' do
      let(:type) { 'silence' }

      it 'silences account' do
        subject
        expect(target_account).to be_silenced
      end
    end

    context 'when type is "suspend"' do
      let(:type) { 'suspend' }

      it 'suspends account' do
        subject
        expect(target_account).to be_suspended
      end

      it 'queues Admin::SuspensionWorker by 1' do
        expect do
          subject
        end.to change { Admin::SuspensionWorker.jobs.size }.by 1
      end
    end

    context 'when type is invalid' do
      let(:type) { 'whatever' }

      it 'raises an invalid record error' do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'when type is not given' do
      let(:type) { '' }

      it 'raises an invalid record error' do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    it 'sends email to target account user', :inline_jobs do
      emails = capture_emails { subject }

      expect(emails).to contain_exactly(
        have_attributes(
          to: contain_exactly(target_account.user.email)
        )
      )
    end

    it 'sends notification, log the action, and closes other reports', :aggregate_failures do
      other_report = Fabricate(:report, target_account: target_account)

      expect { subject }
        .to (change(Admin::ActionLog.where(action: type), :count).by 1)
        .and(change { other_report.reload.action_taken? }.from(false).to(true))

      expect(LocalNotificationWorker).to have_enqueued_sidekiq_job(target_account.id, anything, 'AccountWarning', 'moderation_warning')
    end
  end

  describe '#report' do
    subject { account_action.report }

    context 'with report_id.present?' do
      before do
        account_action.report_id = Fabricate(:report).id
      end

      it 'returns Report' do
        expect(subject).to be_instance_of Report
      end
    end

    context 'with !report_id.present?' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#with_report?' do
    subject { account_action.with_report? }

    context 'with !report.nil?' do
      before do
        account_action.report_id = Fabricate(:report).id
      end

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'with !(!report.nil?)' do
      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '.types_for_account' do
    subject { described_class.types_for_account(account) }

    context 'when Account.local?' do
      let(:account) { Fabricate(:account, domain: nil) }

      it 'returns ["none", "disable", "sensitive", "silence", "suspend"]' do
        expect(subject).to eq %w(none disable sensitive silence suspend)
      end
    end

    context 'with !account.local?' do
      let(:account) { Fabricate(:account, domain: 'hoge.com') }

      it 'returns ["sensitive", "silence", "suspend"]' do
        expect(subject).to eq %w(sensitive silence suspend)
      end
    end
  end
end
