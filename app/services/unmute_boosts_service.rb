# frozen_string_literal: true

class UnmuteBoostsService < BaseService
  def call(account, target_account)
    return unless account.muting_boosts?(target_account)

    account.unmute_boosts!(target_account)

    MergeWorker.perform_async(target_account.id, account.id) if account.following?(target_account)
  end
end
