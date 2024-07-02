# frozen_string_literal: true

class UnmuteService < BaseService
  def call(account, target_account)
    return unless account.muting?(target_account)

    unmute = account.unmute!(target_account)

    TriggerWebhookWithObjectWorker.perform_async('mute.removed', Oj.to_json({ 'account_id': unmute.account_id, 'target_account_id': unmute.target_account_id, 'id': unmute.id }))

    MergeWorker.perform_async(target_account.id, account.id) if account.following?(target_account)
  end
end
