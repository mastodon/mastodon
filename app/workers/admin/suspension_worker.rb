# frozen_string_literal: true

class Admin::SuspensionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(account_id, remove_user = false)
    SuspendAccountService.new.call(Account.find(account_id), remove_user: remove_user)
  end
end
