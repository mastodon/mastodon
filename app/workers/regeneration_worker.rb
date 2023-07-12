# frozen_string_literal: true

class RegenerationWorker
  include Sidekiq::Worker

  sidekiq_options lock: :until_executed

  def perform(account_id, _ = :home)
    ApplicationRecord.connected_to(role: :primary) do
      @account = Account.find(account_id)
    end

    ApplicationRecord.connected_to(role: :read, prevent_writes: true) do
      PrecomputeFeedService.new.call(@account)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end
