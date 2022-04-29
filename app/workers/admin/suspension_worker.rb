# frozen_string_literal: true

class Admin::SuspensionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(account_id)
    SuspendAccountService.new.call(Account.find(account_id))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
