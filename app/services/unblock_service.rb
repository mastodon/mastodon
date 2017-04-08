# frozen_string_literal: true

class UnblockService < BaseService
  def call(account, target_account)
    return unless account.blocking?(target_account)

    unblock = account.unblock!(target_account)
    NotificationWorker.perform_async(build_xml(unblock), account.id, target_account.id) unless target_account.local?
  end

  private

  def build_xml(block)
    AtomSerializer.render(AtomSerializer.new.unblock_salmon(block))
  end
end
