# frozen_string_literal: true

class Scheduler::SuspendedUserCleanupScheduler
  include Sidekiq::Worker

  # Each processed deletion request may enqueue an enormous
  # amount of jobs in the `pull` queue, so only enqueue when
  # the queue is empty or close to being so.
  MAX_PULL_SIZE = 50

  # Since account deletion is very expensive, we want to avoid
  # overloading the server by queing too much at once.
  # This job runs approximately once per 2 minutes, so with a
  # value of `MAX_DELETIONS_PER_JOB` of 10, a server can
  # handle the deletion of 7200 accounts per day, provided it
  # has the capacity for it.
  MAX_DELETIONS_PER_JOB = 10

  sidekiq_options retry: 0

  def perform
    return if Sidekiq::Queue.new('pull').size > MAX_PULL_SIZE

    clean_suspended_accounts!
  end

  private

  def clean_suspended_accounts!
    # This should be fine because we only process a small amount of deletion requests at once and
    # `id` and `created_at` should follow the same order.
    AccountDeletionRequest.reorder(id: :asc).take(MAX_DELETIONS_PER_JOB).each do |deletion_request|
      next unless deletion_request.created_at < AccountDeletionRequest::DELAY_TO_DELETION.ago

      Admin::AccountDeletionWorker.perform_async(deletion_request.account_id)
    end
  end
end
