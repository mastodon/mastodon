# frozen_string_literal: true

class StatusesCountWritebackWorker
  include Sidekiq::Worker

  def perform(account_id)
    account = Account.find(account_id)
    account.update(statuses_count: account.statuses_count(force: true))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
