# frozen_string_literal: true

class MuteService < BaseService
  def call(account, target_account)
    return if account.id == target_account.id
    mute = account.mute!(target_account)
    BlockWorker.perform_async(account.id, target_account.id)
    mute
  end
end
