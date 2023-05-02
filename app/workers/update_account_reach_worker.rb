# frozen_string_literal: true

class UpdateAccountReachWorker
  include Sidekiq::Worker
  include Redisable
  include Lockable

  # This job is using `until_executing` rather than `until_executed` on purpose:
  # with `until_executed`, there exists a time window during which the worker
  # would still hold a lock while not looking at new items in
  # `account_reach:id:to_add`, so there would be no guarantee those items would
  # be processed. `until_executing` ensures anything added while the lock is held
  # will be processed by the worker.
  sidekiq_options queue: 'ingress', lock: :until_executing, retry: 5

  def perform(account_reach_filter_id)
    # Since we are using `until_executing` rather than `until_executed`, lock
    # the whole process to avoid race conditions.
    # Jobs should be very short (far below a second under normal load), so
    # 5 minutes for auto-release sounds like plenty enough to account for
    # high load situations.
    with_lock("consolidate_account_reach_filter:#{account_reach_filter_id}", autorelease: 5.minutes) do
      filter = AccountReachFilter.find_by(id: account_reach_filter_id)
      return if filter.nil? # rubocop:disable Rails/TransactionExitStatement

      with_redis do |redis|
        loop do
          domains = redis.spop("account_reach:#{account_reach_filter_id}:to_add", 50)

          domains.each { |domain| filter.add(domain) }

          break if domains.size < 50
        end
      end

      filter.save!
    end
  end
end
