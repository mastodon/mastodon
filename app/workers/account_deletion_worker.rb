# frozen_string_literal: true

class AccountDeletionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', lock: :until_executed, lock_ttl: 1.week.to_i

  def perform(account_id, options = {})
    account = Account.find(account_id)
    return unless account.suspended?

    reserve_username = options.with_indifferent_access.fetch(:reserve_username, true)
    skip_activitypub = options.with_indifferent_access.fetch(:skip_activitypub, false)
    DeleteAccountService.new.call(account, reserve_username: reserve_username, skip_activitypub: skip_activitypub, reserve_email: false)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
