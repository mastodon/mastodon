# frozen_string_literal: true

class BlockService < BaseService
  include StreamEntryRenderer

  def call(account, target_account)
    return if account.id == target_account.id

    UnfollowService.new.call(account, target_account) if account.following?(target_account)
    UnfollowService.new.call(target_account, account) if target_account.following?(account)

    block = account.block!(target_account)

    BlockWorker.perform_async(account.id, target_account.id)
    NotificationWorker.perform_async(build_xml(block), account.id, target_account.id) unless target_account.local?
  end

  private

  def build_xml(block)
    OStatus::AtomSerializer.render(OStatus::AtomSerializer.new.block_salmon(block))
  end
end
