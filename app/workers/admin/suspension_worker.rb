# frozen_string_literal: true

class Admin::SuspensionWorker
  include Sidekiq::Worker

  def perform(account_id)
    SuspendAccountService.new.call(Account.find(account_id))
  end
end
