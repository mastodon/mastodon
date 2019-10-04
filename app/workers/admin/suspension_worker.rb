# frozen_string_literal: true

class Admin::SuspensionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(account_id, remove_user = false)
    SuspendAccountService.new.call(Account.find(account_id), reserve_username: true, reserve_email: !remove_user)
  end
end
