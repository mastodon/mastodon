# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportHistoryPresenter do
  describe '#logs' do
    subject { described_class.new(report).logs }

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

    it 'returns expected log records' do
      expect(subject)
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
end
