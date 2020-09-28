# frozen_string_literal: true

class AccountDeletionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(account_id)
    DeleteAccountService.new.call(Account.find(account_id), reserve_username: true, reserve_email: false)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
