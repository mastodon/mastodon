# frozen_string_literal: true

class Admin::StatusBatchAction < Admin::BaseAction
  TYPES = %w(
    report
    remove_from_report
  ).freeze

  attr_accessor :status_ids

  private

  def statuses
    Status.with_discarded.where(id: status_ids).reorder(nil)
  end

  def process_action!
    return if status_ids.empty?

    case type
    when 'report'
      handle_report!
    when 'remove_from_report'
      handle_remove_from_report!
    end
  end

  def handle_report!
    @report = Report.new(report_params) unless with_report?
    @report.status_ids = (@report.status_ids + allowed_status_ids).uniq
    @report.save!

    @report_id = @report.id
  end

  def handle_remove_from_report!
    return unless with_report?

    report.status_ids -= status_ids.map(&:to_i)
    report.save!
  end

  def target_account
    @target_account ||= statuses.first.account
  end

  def report_params
    { account: current_account, target_account: target_account }
  end

  def allowed_status_ids
    Admin::AccountStatusesFilter.new(@report.target_account, current_account).results.with_discarded.where(id: status_ids).pluck(:id)
  end
end
