# frozen_string_literal: true

class AddToPublicStatusesIndexWorker
  include Sidekiq::Worker

  def perform(account_id)
    account = Account.find(account_id)

    return unless account.indexable?

    account.add_to_public_statuses_index!
  rescue ActiveRecord::RecordNotFound
    true
  end
end
