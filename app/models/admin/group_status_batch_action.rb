# frozen_string_literal: true

class Admin::GroupStatusBatchAction
  include ActiveModel::Model
  include AccountableConcern
  include Authorization

  attr_accessor :current_account, :type,
                :status_ids, :report_id

  attr_reader :send_email_notification

  def send_email_notification=(value)
    @send_email_notification = ActiveModel::Type::Boolean.new.cast(value)
  end

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
    when 'report'
      handle_report!
    end
  end

  def handle_report!
    statuses.group_by { |status| status.account_id }.values.each do |statuses|
      target_account = statuses.first.account
      allowed_status_ids = AccountStatusesFilter.new(target_account, current_account, include_groups: true).results.with_discarded.where(id: status_ids).pluck(:id)

      report = Report.create!(account: current_account, target_account: target_account, status_ids: allowed_status_ids)

      @report_id = report.id
    end
  end
end
