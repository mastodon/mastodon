# frozen_string_literal: true

class MuteService < BaseService
  def call(account, target_account, notifications: nil)
    return if account.id == target_account.id
    FeedManager.instance.clear_from_timeline(account, target_account)
    # This unwieldy approach avoids duplicating the default value here
    # and in mute!.
    opts = {}
    opts[:notifications] = notifications unless notifications.nil?
    account.mute!(target_account, **opts)
  end
end
