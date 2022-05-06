require 'rails_helper'

RSpec.describe Admin::AccountAction, type: :model do
  let(:account_action) { described_class.new }

  describe '#save!' do
    subject              { account_action.save! }
    let(:account)        { Fabricate(:user, admin: true).account }
    let(:target_account) { Fabricate(:account) }
    let(:type)           { 'disable' }

    before do
      account_action.assign_attributes(
        type:            type,
        current_account: account,
        target_account:  target_account
      )
    end

    context 'type is "disable"' do
      let(:type) { 'disable' }

      it 'disable user' do
        subject
        expect(target_account.user).to be_disabled
      end
    end

    context 'type is "silence"' do
      let(:type) { 'silence' }

      it 'silences account' do
        subject
        expect(target_account).to be_silenced
      end
    end

    context 'type is "suspend"' do
      let(:type) { 'suspend' }

      it 'suspends account' do
        subject
        expect(target_account).to be_suspended
      end

      it 'queues Admin::SuspensionWorker by 1' do
        Sidekiq::Testing.fake! do
          expect do
            subject
          end.to change { Admin::SuspensionWorker.jobs.size }.by 1
        end
      end
    end

    it 'creates Admin::ActionLog' do
      expect do
        subject
      end.to change { Admin::ActionLog.count }.by 1
    end

    it 'calls process_email!' do
      expect(account_action).to receive(:process_email!)
      subject
    end

    it 'calls process_reports!' do
      expect(account_action).to receive(:process_reports!)
      subject
    end
  end

  describe '#report' do
    subject { account_action.report }

    context 'report_id.present?' do
      before do
        account_action.report_id = Fabricate(:report).id
      end

      it 'returns Report' do
        expect(subject).to be_instance_of Report
      end
    end

    context '!report_id.present?' do
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#with_report?' do
    subject { account_action.with_report? }

    context '!report.nil?' do
      before do
        account_action.report_id = Fabricate(:report).id
      end

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context '!(!report.nil?)' do
      it 'returns false' do
        expect(subject).to be false
      end
    end
  end

  describe '.types_for_account' do
    subject { described_class.types_for_account(account) }

    context 'account.local?' do
      let(:account) { Fabricate(:account, domain: nil) }

      it 'returns ["none", "disable", "sensitive", "silence", "suspend"]' do
        expect(subject).to eq %w(none disable sensitive silence suspend)
      end
    end

    context '!account.local?' do
      let(:account) { Fabricate(:account, domain: 'hoge.com') }

      it 'returns ["sensitive", "silence", "suspend"]' do
        expect(subject).to eq %w(sensitive silence suspend)
      end
    end
  end
end
