# frozen_string_literal: true

class Admin::AccountDeletionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', lock: :until_executed, lock_ttl: 1.week.to_i

  def perform(account_id)
    DeleteAccountService.new.call(Account.find(account_id), reserve_username: true, reserve_email: true)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
