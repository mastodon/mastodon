# frozen_string_literal: true

class AddToPublicStatusesIndexWorker
  include Sidekiq::Worker
  include DatabaseHelper

  sidekiq_options queue: 'pull'

  def perform(account_id)
    with_primary do
      @account = Account.find(account_id)
    end

    return unless @account.indexable?

    with_read_replica do
      @account.add_to_public_statuses_index!
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end
