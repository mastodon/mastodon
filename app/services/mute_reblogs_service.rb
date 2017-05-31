# frozen_string_literal: true

class MuteReblogsService < BaseService
  def call(account, target_account)
    return if account.id == target_account.id
    FeedManager.instance.clear_reblogs_from_timeline(account, target_account)
    account.mute_reblogs!(target_account)
  end
end
