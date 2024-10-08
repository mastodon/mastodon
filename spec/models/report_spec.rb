# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Report do
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
