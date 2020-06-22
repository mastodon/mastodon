# frozen_string_literal: true

class RegenerationWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed

  def perform(account_id, _ = :home)
    account = Account.find(account_id)
    PrecomputeFeedService.new.call(account)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
