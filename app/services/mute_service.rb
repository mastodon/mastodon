# frozen_string_literal: true

class MuteService < BaseService
  def call(account, target_account, notifications: nil, duration: 0)
    return if account.id == target_account.id

    mute = account.mute!(target_account, notifications: notifications, duration: duration)

    if mute.hide_notifications?
      BlockWorker.perform_async(account.id, target_account.id)
    else
      MuteWorker.perform_async(account.id, target_account.id)
    end

    DeleteMuteWorker.perform_at(duration.seconds, mute.id) if duration != 0

    mute
  end
end
