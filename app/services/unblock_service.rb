# frozen_string_literal: true

class UnblockService < BaseService
  include StreamEntryRenderer

  def call(account, target_account)
    return unless account.blocking?(target_account)

    unblock = account.unblock!(target_account)
    NotificationWorker.perform_async(stream_entry_to_xml(unblock.stream_entry), account.id, target_account.id) unless target_account.local?
  end
end
