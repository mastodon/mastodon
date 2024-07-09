# frozen_string_literal: true

class UnmuteService < BaseService
  def call(account, target_account)
    return unless account.muting?(target_account)

    account.unmute!(target_account)

    MergeWorker.perform_async(target_account.id, account.id) if account.following?(target_account)

    notify_streaming!
  end

  private

  def notify_streaming!
    redis.publish('system', Oj.dump(event: :mutes_changed, account: @account.id, target_account: @target_account.id))
  end
end
