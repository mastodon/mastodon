# frozen_string_literal: true

class Admin::StatusBatchAction
  include ActiveModel::Model
  include AccountableConcern
  include Authorization

  attr_accessor :current_account, :type,
                :status_ids, :report_id

  def save!
    process_action!
  end

  private

  def statuses
    Status.with_discarded.where(id: status_ids)
  end

  def process_action!
    return if status_ids.empty?

    case type
    when 'delete'
      handle_delete!
    when 'report'
      handle_report!
    when 'remove_from_report'
      handle_remove_from_report!
    end
  end

  def handle_delete!
    statuses.each { |status| authorize(status, :destroy?) }

    ApplicationRecord.transaction do
      statuses.each do |status|
        status.discard
        log_action(:destroy, status)
      end

      if with_report?
        report.resolve!(current_account)
        log_action(:resolve, report)
      end

      @warning = target_account.strikes.create!(
        action: :delete_statuses,
        account: current_account,
        report: report,
        status_ids: status_ids
      )

      statuses.each { |status| Tombstone.find_or_create_by(uri: status.uri, account: status.account, by_moderator: true) } unless target_account.local?
    end

    UserMailer.warning(target_account.user, @warning).deliver_later! if target_account.local?
    RemovalWorker.push_bulk(status_ids) { |status_id| [status_id, { 'preserve' => target_account.local?, 'immediate' => !target_account.local? }] }
  end

  def handle_report!
    @report = Report.new(report_params) unless with_report?
    @report.status_ids = (@report.status_ids + status_ids.map(&:to_i)).uniq
    @report.save!

    @report_id = @report.id
  end

  def handle_remove_from_report!
    return unless with_report?

    report.status_ids -= status_ids.map(&:to_i)
    report.save!
  end

  def report
    @report ||= Report.find(report_id) if report_id.present?
  end

  def with_report?
    !report.nil?
  end

  def target_account
    @target_account ||= statuses.first.account
  end

  def report_params
    { account: current_account, target_account: target_account }
  end
end
