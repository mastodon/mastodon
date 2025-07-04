# frozen_string_literal: true

class ReportHistoryPresenter
  attr_reader :report

  def initialize(report)
    @report = report
  end

  def logs
    Admin::ActionLog
      .latest
      .from(Arel::Nodes::As.new(subquery, Admin::ActionLog.arel_table))
  end

  private

  def subquery
    related_logs
      .map(&:arel)
      .reduce { |union, query| Arel::Nodes::UnionAll.new(union, query) }
  end

  def related_logs
    [
      logs_for('Report', report.id),
      logs_for('Account', report.target_account_id),
      logs_for('Status', report.status_ids),
      logs_for('AccountWarning', report_account_warning_ids),
    ]
  end

  def logs_for(target_type, target_id)
    Admin::ActionLog
      .where(target_type:, target_id:)
  end

  def report_account_warning_ids
    AccountWarning
      .where(report_id: report.id)
      .select(:id)
  end
end
