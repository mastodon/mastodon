# frozen_string_literal: true

module AccountStatusesSearch
  extend ActiveSupport::Concern

  def enqueue_update_public_statuses_index
    if discoverable?
      enqueue_add_to_public_statuses_index
    else
      enqueue_remove_from_public_statuses_index
    end
  end

  def enqueue_add_to_public_statuses_index
    return unless Chewy.enabled?

    AddToPublicStatusesIndexWorker.perform_async(id)
  end

  def enqueue_remove_from_public_statuses_index
    return unless Chewy.enabled?

    RemoveFromPublicStatusesIndexWorker.perform_async(id)
  end

  def add_to_public_statuses_index!
    return unless Chewy.enabled?

    Status.where(account_id: id).find_in_batches(batch_size: 1_000) do |batch|
      puts batch
      Chewy.strategy(:sidekiq) do
        PublicStatusesIndex.import(query: batch)
      end
    end
  end

  def remove_from_public_statuses_index!
    return unless Chewy.enabled?

    PublicStatusesIndex.filter(term: { account_id: id }).delete_all
  end
end
