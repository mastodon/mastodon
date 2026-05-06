# frozen_string_literal: true

class Admin::AccountDeletionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', lock: :until_executed, lock_ttl: 1.week.to_i

  def perform(account_id)
    delete_account = Account.find(account_id)
    return unless delete_account.unavailable?

    DeleteAccountService.new.call(delete_account, reserve_username: true, reserve_email: true)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
