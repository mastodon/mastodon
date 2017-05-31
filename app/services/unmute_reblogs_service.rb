# frozen_string_literal: true

class UnmuteReblogsService < BaseService
  def call(account, target_account)
    return unless account.muting_reblogs?(target_account)

    account.unmute_reblogs!(target_account)

    MergeWorker.perform_async(target_account.id, account.id) if account.following?(target_account)
  end
end
