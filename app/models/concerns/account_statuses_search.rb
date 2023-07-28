# frozen_string_literal: true

module AccountStatusesSearch
  extend ActiveSupport::Concern

  def enqueue_update_statuses_index
    UpdateStatusIndexWorker.perform_async(id)
  end

  def update_statuses_index!
    return unless Chewy.enabled?

    batch_size = 1000
    offset = 0

    loop do
      batch = Status.where(account_id: id).offset(offset).limit(batch_size)

      break if batch.empty?

      Chewy.strategy(:sidekiq) do
        StatusesIndex.import(query: batch)
      end

      offset += batch_size
    end
  end
end
