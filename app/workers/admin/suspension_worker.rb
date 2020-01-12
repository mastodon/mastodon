# frozen_string_literal: true

class Admin::SuspensionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(account_id, options = {})
    SuspendAccountService.new.call(Account.find(account_id), **options.symbolize_keys)
  end
end
