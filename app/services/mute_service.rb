# frozen_string_literal: true

##
# Mutes a +target_account+ for +account+.
#
# Fans out by inserting block and/or mute jobs depending on the +Mute+ object
# returned by the +account.mute+ call.
#
# +account+ is the account performing the block.
# +target_account+ is the account being blocked by +account+.
class MuteService < BaseService
  def call(account, target_account, notifications: nil)
    return if account.id == target_account.id

    mute = account.mute!(target_account, notifications: notifications)

    if mute.hide_notifications?
      BlockWorker.perform_async(account.id, target_account.id)
    else
      MuteWorker.perform_async(account.id, target_account.id)
    end

    mute
  end
end
