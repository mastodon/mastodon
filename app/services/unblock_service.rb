# frozen_string_literal: true

class UnblockService < BaseService
  def call(account, target_account)
    return unless account.blocking?(target_account)

    unblock = account.unblock!(target_account)
    NotificationWorker.perform_async(unblock.stream_entry.id, target_account.id) unless target_account.local?
  end
end
