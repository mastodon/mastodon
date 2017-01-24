# frozen_string_literal: true

class BlockService < BaseService
  def call(account, target_account)
    return if account.id == target_account.id

    UnfollowService.new.call(account, target_account) if account.following?(target_account)
    UnfollowService.new.call(target_account, account) if target_account.following?(account)

    block = account.block!(target_account)

    BlockWorker.perform_async(account.id, target_account.id)
    NotificationWorker.perform_async(block.stream_entry.id, target_account.id) unless target_account.local?
  end
end
