# frozen_string_literal: true

class Admin::AccountDeletionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', lock: :until_executed, lock_ttl: 1.week.to_i

  def perform(account_id)
    deleteAccount = Account.find(account_id)
    return unless deleteAccount.unavailable?

    DeleteAccountService.new.call(deleteAccount, reserve_username: true, reserve_email: true)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
