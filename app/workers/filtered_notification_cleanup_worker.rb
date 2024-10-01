# frozen_string_literal: true

class FilteredNotificationCleanupWorker
  include Sidekiq::Worker

  def perform(account_id, from_account_id)
    Notification.where(account_id: account_id, from_account_id: from_account_id, filtered: true).reorder(nil).in_batches(order: :desc).delete_all
  end
end
