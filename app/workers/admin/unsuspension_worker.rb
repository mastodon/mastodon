# frozen_string_literal: true

class Admin::UnsuspensionWorker < ApplicationWorker
  sidekiq_options queue: 'pull'

  def perform(account_id)
    UnsuspendAccountService.new.call(Account.find(account_id))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
