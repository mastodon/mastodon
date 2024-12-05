# frozen_string_literal: true

class Admin::AccountAction
  include ActiveModel::Model
  include AccountableConcern
  include Authorization

  TYPES = %w(
    none
    disable
    sensitive
    silence
    suspend
  ).freeze

  attr_accessor :target_account,
                :current_account,
                :type,
                :text,
                :report_id,
                :warning_preset_id

  attr_reader :warning, :send_email_notification, :include_statuses

  alias send_email_notification? send_email_notification
  alias include_statuses? include_statuses

  validates :type, :target_account, :current_account, presence: true
  validates :type, inclusion: { in: TYPES }

  def initialize(attributes = {})
    @send_email_notification = true
    @include_statuses        = true

    super
  end

  def send_email_notification=(value)
    @send_email_notification = ActiveModel::Type::Boolean.new.cast(value)
  end

  def include_statuses=(value)
    @include_statuses = ActiveModel::Type::Boolean.new.cast(value)
  end

  def save!
    raise ActiveRecord::RecordInvalid, self unless valid?

    ApplicationRecord.transaction do
      process_action!
      process_strike!
      process_reports!
    end

    process_notification!
    process_queue!
  end

  def report
    @report ||= Report.find(report_id) if report_id.present?
  end

  def with_report?
    !report.nil?
  end

  class << self
    def types_for_account(account)
      if account.local?
        TYPES
      else
        TYPES - %w(none disable)
      end
    end

    def disabled_types_for_account(account)
      if account.suspended_locally?
        %w(silence suspend)
      elsif account.silenced?
        %w(silence)
      end
    end

    def i18n_scope
      :activerecord
    end
  end

  private

  def process_action!
    case type
    when 'disable'
      handle_disable!
    when 'sensitive'
      handle_sensitive!
    when 'silence'
      handle_silence!
    when 'suspend'
      handle_suspend!
    end
  end

  def process_strike!
    @warning = target_account.strikes.create!(
      account: current_account,
      report: report,
      action: type,
      text: text_for_warning,
      status_ids: status_ids
    )

    # A log entry is only interesting if the warning contains
    # custom text from someone. Otherwise it's just noise.
    log_action(:create, @warning) if @warning.text.present? && type == 'none'
  end

  def process_reports!
    # If we're doing "mark as resolved" on a single report,
    # then we want to keep other reports open in case they
    # contain new actionable information.
    #
    # Otherwise, we will mark all unresolved reports about
    # the account as resolved.

    reports.each do |report|
      authorize(report, :update?)
      log_action(:resolve, report)
      report.resolve!(current_account)
    end
  end

  def handle_disable!
    authorize(target_account.user, :disable?)
    log_action(:disable, target_account.user)
    target_account.user&.disable!
  end

  def handle_sensitive!
    authorize(target_account, :sensitive?)
    log_action(:sensitive, target_account)
    target_account.sensitize!
  end

  def handle_silence!
    authorize(target_account, :silence?)
    log_action(:silence, target_account)
    target_account.silence!
  end

  def handle_suspend!
    authorize(target_account, :suspend?)
    log_action(:suspend, target_account)
    target_account.suspend!(origin: :local)
  end

  def text_for_warning
    [warning_preset&.text, text].compact.join("\n\n")
  end

  def queue_suspension_worker!
    Admin::SuspensionWorker.perform_async(target_account.id)
  end

  def process_queue!
    queue_suspension_worker! if type == 'suspend'
  end

  def process_notification!
    return unless warnable?

    UserMailer.warning(target_account.user, warning).deliver_later!
    LocalNotificationWorker.perform_async(target_account.id, warning.id, 'AccountWarning', 'moderation_warning')
  end

  def warnable?
    send_email_notification? && target_account.local?
  end

  def status_ids
    report.status_ids if with_report? && include_statuses?
  end

  def reports
    @reports ||= if type == 'none'
                   with_report? ? [report] : []
                 else
                   Report.where(target_account: target_account).unresolved
                 end
  end

  def warning_preset
    @warning_preset ||= AccountWarningPreset.find(warning_preset_id) if warning_preset_id.present?
  end
end
