# frozen_string_literal: true

class RemoveFromPublicStatusesIndexWorker
  include Sidekiq::Worker

  def perform(account_id)
    account = Account.find(account_id)

    return if account.indexable?

    account.remove_from_public_statuses_index!
  rescue ActiveRecord::RecordNotFound
    true
  end
end
