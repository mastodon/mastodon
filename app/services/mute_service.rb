# frozen_string_literal: true

class MuteService < BaseService
  def call(account, target_account, **opts)
    return if account.id == target_account.id
    FeedManager.instance.clear_from_timeline(account, target_account)
    mute = account.mute!(target_account, **opts.slice(:notifications))
    BlockWorker.perform_async(account.id, target_account.id)
    mute
  end
end
