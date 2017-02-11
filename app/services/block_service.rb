# frozen_string_literal: true

class BlockService < BaseService
  include StreamEntryRenderer

  def call(account, target_account)
    return if account.id == target_account.id

    UnfollowService.new.call(account, target_account) if account.following?(target_account)
    UnfollowService.new.call(target_account, account) if target_account.following?(account)

    block = account.block!(target_account)

    BlockWorker.perform_async(account.id, target_account.id)
    NotificationWorker.perform_async(stream_entry_to_xml(block.stream_entry), account.id, target_account.id) unless target_account.local?
  end
end
