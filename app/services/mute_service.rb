# frozen_string_literal: true

class MuteService < BaseService
  def call(account, target_account)
    return if account.id == target_account.id
    FeedManager.instance.clear_from_timeline(account, target_account)
    account.mute!(target_account)
  end
end
