# frozen_string_literal: true

class UnsilenceWorker
  include Sidekiq::Worker

  def perform(account_id)
    Account.find(account_id).update(silenced: true)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
