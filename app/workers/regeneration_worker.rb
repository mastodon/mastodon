# frozen_string_literal: true

class RegenerationWorker
  include Sidekiq::Worker
  include DatabaseHelper

  sidekiq_options lock: :until_executed

  def perform(account_id, _ = :home)
    with_primary do
      @account = Account.find(account_id)
    end

    with_read_replica do
      PrecomputeFeedService.new.call(@account)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end
