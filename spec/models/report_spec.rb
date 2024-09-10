# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Report do
  let(:local_account) { Fabricate(:account, domain: nil) }
  let(:remote_account) { Fabricate(:account, domain: 'example.com') }

  describe 'statuses' do
    it 'returns the statuses for the report' do
      status = Fabricate(:status)
      _other = Fabricate(:status)
      report = Fabricate(:report, status_ids: [status.id])

      expect(report.statuses).to eq [status]
    end
  end

  describe 'media_attachments_count' do
    it 'returns count of media attachments in statuses' do
      status1 = Fabricate(:status, ordered_media_attachment_ids: [1, 2])
      status2 = Fabricate(:status, ordered_media_attachment_ids: [5])
      report  = Fabricate(:report, status_ids: [status1.id, status2.id])

      expect(report.media_attachments_count).to eq 3
    end
  end

  describe 'forwardable?' do
    it 'returns true if the target account is not local' do
      report = Fabricate(:report, target_account: remote_account)

      expect(report.forwardable?).to be true
    end

    it 'returns false if the target account is local' do
      report = Fabricate(:report, target_account: local_account)

      expect(report.forwardable?).to be false
    end
  end

  describe 'forwardable_to_domains' do
    context 'when the reporting account is not local' do
      let(:report) { Fabricate(:report, account: remote_account, target_account: local_account) }

      it 'returns an empty list' do
        expect(report.forwardable_to_domains).to eql []
      end
    end

    context 'when the reported account is local' do
      let(:report) { Fabricate(:report, target_account: local_account, account: local_account) }

      it 'returns an empty list' do
        expect(report.forwardable_to_domains).to eql []
      end
    end

    context 'when the reported account is local and the statuses are in a thread with remote participants' do
      let(:remote_thread_account) { Fabricate(:account, domain: 'foo.com') }
      let(:reported_status) { Fabricate(:status, account: local_account, thread: Fabricate(:status, account: remote_thread_account)) }
      let(:report) { Fabricate(:report, target_account: local_account, account: local_account, status_ids: [reported_status.id]) }

      it 'returns a list of all participating domains' do
        expect(report.forwardable_to_domains).to eql ['foo.com']
      end
    end

    context 'when the reported account is remote and the statuses are in a thread with remote participants' do
      let(:remote_thread_account) { Fabricate(:account, domain: 'foo.com') }
      let(:reported_status) { Fabricate(:status, account: remote_account, thread: Fabricate(:status, account: remote_thread_account)) }
      let(:report) { Fabricate(:report, target_account: remote_account, account: local_account, status_ids: [reported_status.id]) }

      it 'returns a list of all participating domains' do
        expect(report.forwardable_to_domains).to eql ['example.com', 'foo.com']
      end
    end

    context 'when the reported account is remote and the statuses are in a thread with participants on the same server' do
      let(:remote_thread_account) { Fabricate(:account, domain: 'example.com') }
      let(:reported_status) { Fabricate(:status, account: remote_account, thread: Fabricate(:status, account: remote_thread_account)) }
      let(:report) { Fabricate(:report, target_account: remote_account, account: local_account, status_ids: [reported_status.id]) }

      it 'returns a list of all participating domains without duplicates' do
        expect(report.forwardable_to_domains).to eql ['example.com']
      end
    end

    context 'when the reported account is remote and the status is not in a thread' do
      let(:reported_status) { Fabricate(:status, account: remote_account) }
      let(:report) { Fabricate(:report, target_account: remote_account, account: local_account, status_ids: [reported_status.id]) }

      it 'returns a list of just the domain of the reported account' do
        expect(report.forwardable_to_domains).to eql ['example.com']
      end
    end
  end

  describe 'assign_to_self!' do
    subject { report.assigned_account_id }

    let(:report) { Fabricate(:report, assigned_account_id: original_account) }
    let(:original_account) { Fabricate(:account) }
    let(:current_account) { Fabricate(:account) }

    before do
      report.assign_to_self!(current_account)
    end

    it 'assigns to a given account' do
      expect(subject).to eq current_account.id
    end
  end

  describe 'unassign!' do
    subject { report.assigned_account_id }

    let(:report) { Fabricate(:report, assigned_account_id: account.id) }
    let(:account) { Fabricate(:account) }

    before do
      report.unassign!
    end

    it 'unassigns' do
      expect(subject).to be_nil
    end
  end

  describe 'resolve!' do
    subject(:report) { Fabricate(:report, action_taken_at: nil, action_taken_by_account_id: nil) }

    let(:acting_account) { Fabricate(:account) }

    before do
      report.resolve!(acting_account)
    end

    it 'records action taken' do
      expect(report.action_taken?).to be true
      expect(report.action_taken_by_account_id).to eq acting_account.id
    end
  end

  describe 'unresolve!' do
    subject(:report) { Fabricate(:report, action_taken_at: Time.now.utc, action_taken_by_account_id: acting_account.id) }

    let(:acting_account) { Fabricate(:account) }

    before do
      report.unresolve!
    end

    it 'unresolves' do
      expect(report.action_taken?).to be false
      expect(report.action_taken_by_account_id).to be_nil
    end
  end

  describe 'unresolved?' do
    subject { report.unresolved? }

    let(:report) { Fabricate(:report, action_taken_at: action_taken) }

    context 'when action is taken' do
      let(:action_taken) { Time.now.utc }

      it { is_expected.to be false }
    end

    context 'when action not is taken' do
      let(:action_taken) { nil }

      it { is_expected.to be true }
    end
  end

  describe 'history' do
    subject(:action_logs) { report.history }

    let(:report) { Fabricate(:report, target_account_id: target_account.id, status_ids: [status.id], created_at: 3.days.ago, updated_at: 1.day.ago) }
    let(:target_account) { Fabricate(:account) }
    let(:status) { Fabricate(:status) }

    before do
      Fabricate(:action_log, target_type: 'Report', account_id: target_account.id, target_id: report.id, created_at: 2.days.ago)
      Fabricate(:action_log, target_type: 'Account', account_id: target_account.id, target_id: report.target_account_id, created_at: 2.days.ago)
      Fabricate(:action_log, target_type: 'Status', account_id: target_account.id, target_id: status.id, created_at: 2.days.ago)
    end

    it 'returns right logs' do
      expect(action_logs.count).to eq 3
    end
  end

  describe 'validations' do
    let(:remote_account) { Fabricate(:account, domain: 'example.com', protocol: :activitypub, inbox_url: 'http://example.com/inbox') }

    it 'is invalid if comment is longer than character limit and reporter is local' do
      report = Fabricate.build(:report, comment: comment_over_limit)
      expect(report.valid?).to be false
      expect(report).to model_have_error_on_field(:comment)
    end

    it 'is valid if comment is longer than character limit and reporter is not local' do
      report = Fabricate.build(:report, account: remote_account, comment: comment_over_limit)
      expect(report.valid?).to be true
    end

    it 'is invalid if it references invalid rules' do
      report = Fabricate.build(:report, category: :violation, rule_ids: [-1])
      expect(report.valid?).to be false
      expect(report).to model_have_error_on_field(:rule_ids)
    end

    it 'is invalid if it references rules but category is not "violation"' do
      rule = Fabricate(:rule)
      report = Fabricate.build(:report, category: :spam, rule_ids: rule.id)
      expect(report.valid?).to be false
      expect(report).to model_have_error_on_field(:rule_ids)
    end

    def comment_over_limit
      'a' * described_class::COMMENT_SIZE_LIMIT * 2
    end
  end
end
