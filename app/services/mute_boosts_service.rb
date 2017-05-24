# frozen_string_literal: true

class MuteBoostsService < BaseService
  def call(account, target_account)
    return if account.id == target_account.id
    FeedManager.instance.clear_boosts_from_timeline(account, target_account)
    account.mute_boosts!(target_account)
  end
end
