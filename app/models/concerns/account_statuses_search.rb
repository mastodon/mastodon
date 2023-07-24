# frozen_string_literal: true

module AccountStatusesSearch
  extend ActiveSupport::Concern

  def enqueue_update_statuses_index
    UpdateStatusIndexWorker.perform_async(id)
  end

  def update_statuses_index!
    return unless Chewy.enabled?

    # This might not scale if a user has a TON of statuses.
    # If that is the case, perhaps for users with many statuses, we should:
    # (1) get all their statuses and (2) submit requests to ES in batches.
    Chewy.strategy(:sidekiq) do
      StatusesIndex.import(query: Status.where(account_id: id))
    end
  end
end
