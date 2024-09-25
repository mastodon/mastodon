# frozen_string_literal: true

module Account::StatusesSearch
  extend ActiveSupport::Concern

  included do
    after_update_commit :enqueue_update_public_statuses_index, if: :saved_change_to_indexable?
    after_destroy_commit :enqueue_remove_from_public_statuses_index, if: :indexable?
  end

  def enqueue_update_public_statuses_index
    if indexable?
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

    statuses.without_reblogs.public_visibility.reorder(nil).find_in_batches do |batch|
      PublicStatusesIndex.import(batch)
    end
  end

  def remove_from_public_statuses_index!
    return unless Chewy.enabled?

    PublicStatusesIndex.filter(term: { account_id: id }).delete_all
  end
end
