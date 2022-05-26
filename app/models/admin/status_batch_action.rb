# frozen_string_literal: true

class Admin::StatusBatchAction
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
    when 'delete'
      handle_delete!
    when 'mark_as_sensitive'
      handle_mark_as_sensitive!
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

    UserMailer.warning(target_account.user, @warning).deliver_later! if warnable?
    RemovalWorker.push_bulk(status_ids) { |status_id| [status_id, { 'preserve' => target_account.local?, 'immediate' => !target_account.local? }] }
  end

  def handle_mark_as_sensitive!
    representative_account = Account.representative

    # Can't use a transaction here because UpdateStatusService queues
    # Sidekiq jobs
    statuses.includes(:media_attachments, :preview_cards).find_each do |status|
      next unless status.with_media? || status.with_preview_card?

      authorize(status, :update?)

      if target_account.local?
        UpdateStatusService.new.call(status, representative_account.id, sensitive: true)
      else
        status.update(sensitive: true)
      end

      log_action(:update, status)

      if with_report?
        report.resolve!(current_account)
        log_action(:resolve, report)
      end

      @warning = target_account.strikes.create!(
        action: :mark_statuses_as_sensitive,
        account: current_account,
        report: report,
        status_ids: status_ids
      )
    end

    UserMailer.warning(target_account.user, @warning).deliver_later! if warnable?
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

  def report
    @report ||= Report.find(report_id) if report_id.present?
  end

  def with_report?
    !report.nil?
  end

  def warnable?
    send_email_notification && target_account.local?
  end

  def target_account
    @target_account ||= statuses.first.account
  end

  def report_params
    { account: current_account, target_account: target_account }
  end

  def allowed_status_ids
    AccountStatusesFilter.new(@report.target_account, current_account).results.with_discarded.where(id: status_ids).pluck(:id)
  end
end
