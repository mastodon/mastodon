# frozen_string_literal: true

class ApproveAppealService < BaseService
  def call(appeal, current_account)
    @appeal          = appeal
    @strike          = appeal.strike
    @current_account = current_account

    ApplicationRecord.transaction do
      undo_strike_action!
      mark_strike_as_appealed!
    end

    queue_workers!
    notify_target_account!
  end

  private

  def target_account
    @strike.target_account
  end

  def undo_strike_action!
    case @strike.action
    when 'disable'
      undo_disable!
    when 'delete_statuses'
      undo_delete_statuses!
    when 'mark_statuses_as_sensitive'
      undo_mark_statuses_as_sensitive!
    when 'sensitive'
      undo_sensitive!
    when 'silence'
      undo_silence!
    when 'suspend'
      undo_suspend!
    end
  end

  def mark_strike_as_appealed!
    @appeal.approve!(@current_account)
    @strike.touch(:overruled_at)
  end

  def undo_disable!
    target_account.user.enable!
  end

  def undo_delete_statuses!
    # Cannot be undone
  end

  def undo_mark_statuses_as_sensitive!
    representative_account = Account.representative
    @strike.statuses.kept.includes(:media_attachments).reorder(nil).find_each do |status|
      UpdateStatusService.new.call(status, representative_account.id, sensitive: false) if status.with_media?
    end
  end

  def undo_sensitive!
    target_account.unsensitize!
  end

  def undo_silence!
    target_account.unsilence!
  end

  def undo_suspend!
    target_account.unsuspend!
  end

  def queue_workers!
    case @strike.action
    when 'suspend'
      Admin::UnsuspensionWorker.perform_async(target_account.id)
    end
  end

  def notify_target_account!
    UserMailer.appeal_approved(target_account.user, @appeal).deliver_later
  end
end
