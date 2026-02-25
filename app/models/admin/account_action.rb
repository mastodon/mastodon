# frozen_string_literal: true

class Admin::AccountAction < Admin::BaseAction
  TYPES = %w(
    none
    disable
    sensitive
    silence
    suspend
  ).freeze

  attr_accessor :target_account,
                :warning_preset_id

  attribute :include_statuses, :boolean, default: true

  alias include_statuses? include_statuses

  validates :target_account, presence: true

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
    ApplicationRecord.transaction do
      handle_type!
      process_strike!
      process_reports!
    end

    process_notification!
    process_queue!
  end

  def handle_type!
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

  def status_ids
    report.status_ids if with_report? && include_statuses?
  end

  def reports
    @reports ||= if type == 'none'
                   with_report? ? [report] : []
                 else
                   target_account.targeted_reports.unresolved
                 end
  end

  def warning_preset
    @warning_preset ||= AccountWarningPreset.find(warning_preset_id) if warning_preset_id.present?
  end
end
