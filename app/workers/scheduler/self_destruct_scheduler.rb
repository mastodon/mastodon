# frozen_string_literal: true

class Scheduler::SelfDestructScheduler
  include Sidekiq::Worker
  include SelfDestructHelper

  MAX_ENQUEUED = 10_000
  MAX_REDIS_MEM_USAGE = 0.5
  MAX_ACCOUNT_DELETIONS_PER_JOB = 50

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 1.day.to_i

  def perform
    return unless self_destruct?
    return if sidekiq_overwhelmed?

    delete_accounts!
  end

  private

  def sidekiq_overwhelmed?
    redis_mem_info = Sidekiq.default_configuration.redis_info
    maxmemory = [redis_mem_info['maxmemory'].to_f, redis_mem_info['total_system_memory'].to_f].filter(&:positive?).min

    Sidekiq::Stats.new.enqueued > MAX_ENQUEUED || redis_mem_info['used_memory'].to_f > maxmemory * MAX_REDIS_MEM_USAGE
  end

  def delete_accounts!
    # We currently do not distinguish between deleted accounts and suspended
    # accounts, and we do not want to remove the records in this scheduler, as
    # we still rely on it for account delivery and don't want to perform
    # needless work when the database can be outright dropped after the
    # self-destruct.
    # Deleted accounts are suspended accounts that do not have a pending
    # deletion request.

    # This targets accounts that have not been deleted nor marked for deletion yet
    Account.local.without_suspended.reorder(id: :asc).take(MAX_ACCOUNT_DELETIONS_PER_JOB).each do |account|
      delete_account!(account)
    end

    return if sidekiq_overwhelmed?

    # This targets accounts that have been marked for deletion but have not been
    # deleted yet
    Account.local.suspended.joins(:deletion_request).take(MAX_ACCOUNT_DELETIONS_PER_JOB).each do |account|
      delete_account!(account)
      account.deletion_request&.destroy
    end
  end

  def inboxes
    @inboxes ||= Account.inboxes
  end

  def delete_account!(account)
    payload = ActiveModelSerializers::SerializableResource.new(
      account,
      serializer: ActivityPub::DeleteActorSerializer,
      adapter: ActivityPub::Adapter
    ).as_json

    json = Oj.dump(ActivityPub::LinkedDataSignature.new(payload).sign!(account))

    ActivityPub::DeliveryWorker.push_bulk(inboxes, limit: 1_000) do |inbox_url|
      [json, account.id, inbox_url]
    end

    # Do not call `Account#suspend!` because we don't want to issue a deletion request
    account.update!(suspended_at: Time.now.utc, suspension_origin: :local)
  end
end
