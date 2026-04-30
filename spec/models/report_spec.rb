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

  describe 'history' do
    subject(:action_logs) { report.history }

    let(:report) { Fabricate(:report, target_account_id: target_account.id, status_ids: [status.id]) }
    let(:target_account) { Fabricate(:account) }
    let(:status) { Fabricate(:status) }
    let(:account_warning) { Fabricate(:account_warning, report_id: report.id) }

    let!(:matched_type_account_warning) { Fabricate(:action_log, target_type: 'AccountWarning', target_id: account_warning.id) }
    let!(:matched_type_account) { Fabricate(:action_log, target_type: 'Account', target_id: report.target_account_id) }
    let!(:matched_type_report) { Fabricate(:action_log, target_type: 'Report', target_id: report.id) }
    let!(:matched_type_status) { Fabricate(:action_log, target_type: 'Status', target_id: status.id) }

    let!(:unmatched_type_account_warning) { Fabricate(:action_log, target_type: 'AccountWarning') }
    let!(:unmatched_type_account) { Fabricate(:action_log, target_type: 'Account') }
    let!(:unmatched_type_report) { Fabricate(:action_log, target_type: 'Report') }
    let!(:unmatched_type_status) { Fabricate(:action_log, target_type: 'Status') }

    it 'returns expected logs' do
      expect(action_logs)
        .to have_attributes(count: 4)
        .and include(matched_type_account_warning)
        .and include(matched_type_account)
        .and include(matched_type_report)
        .and include(matched_type_status)
        .and not_include(unmatched_type_account_warning)
        .and not_include(unmatched_type_account)
        .and not_include(unmatched_type_report)
        .and not_include(unmatched_type_status)
    end
  end

  describe 'Delegations' do
    it { is_expected.to delegate_method(:local?).to(:account) }
  end

  describe 'Validations' do
    let(:remote_account) { Fabricate(:account, domain: 'example.com', protocol: :activitypub, inbox_url: 'http://example.com/inbox') }

    it 'is invalid if comment is longer than character limit and reporter is local' do
      report = Fabricate.build(:report)

      expect(report).to_not allow_value(comment_over_limit).for(:comment)
    end

    it 'is valid if comment is longer than character limit and reporter is not local' do
      report = Fabricate.build(:report, account: remote_account, comment: comment_over_limit)
      expect(report.valid?).to be true
    end

    it 'is invalid if it references invalid rules' do
      report = Fabricate.build(:report, category: :violation)

      expect(report).to_not allow_value([-1]).for(:rule_ids)
    end

    it 'is invalid if it references rules but category is not "violation"' do
      rule = Fabricate(:rule)
      report = Fabricate.build(:report, category: :spam)

      expect(report).to_not allow_value(rule.id).for(:rule_ids)
    end

    def comment_over_limit
      'a' * described_class::COMMENT_SIZE_LIMIT * 2
    end
  end
end
