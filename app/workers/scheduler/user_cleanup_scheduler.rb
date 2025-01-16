# frozen_string_literal: true

class Scheduler::UserCleanupScheduler
  include Sidekiq::Worker

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 1.day.to_i

  def perform
    clean_unconfirmed_accounts!
    clean_discarded_statuses!
  end

  private

  def clean_unconfirmed_accounts!
    User.where('confirmed_at is NULL AND confirmation_sent_at <= ?', 2.days.ago).reorder(nil).find_in_batches do |batch|
      # We have to do it separately because of missing database constraints
      AccountModerationNote.where(target_account_id: batch.map(&:account_id)).delete_all
      WebauthnCredential.where(user_id: batch.map(&:id)).delete_all
      Account.where(id: batch.map(&:account_id)).delete_all
      User.where(id: batch.map(&:id)).delete_all
    end
  end

  def clean_discarded_statuses!
    Status.unscoped.discarded.where('deleted_at <= ?', 30.days.ago).find_in_batches do |statuses|
      RemovalWorker.push_bulk(statuses) do |status|
        [status.id, { 'immediate' => true, 'skip_streaming' => true }]
      end
    end
  end
end
