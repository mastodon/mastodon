# frozen_string_literal: true

class ApproveAppealService < BaseService
  def call(appeal)
    @appeal = appeal
    @strike = appeal.strike

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
    when 'sensitive'
      undo_sensitive!
    when 'silence'
      undo_silence!
    when 'suspend'
      undo_suspend!
    end
  end

  def mark_strike_as_appealed!
    @strike.touch(:appealed_at)
  end

  def undo_disable!
    target_account.user.enable!
  end

  def undo_delete_statuses!
    @strike.statuses.each(&:undiscard)
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
