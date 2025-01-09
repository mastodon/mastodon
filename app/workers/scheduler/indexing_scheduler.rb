# frozen_string_literal: true

class Scheduler::IndexingScheduler
  include Sidekiq::Worker
  include Redisable
  include DatabaseHelper

  sidekiq_options retry: 0, lock: :until_executed, lock_ttl: 30.minutes.to_i

  IMPORT_BATCH_SIZE = 1000
  SCAN_BATCH_SIZE = 10 * IMPORT_BATCH_SIZE

  def perform
    return unless Chewy.enabled?

    indexes.each do |type|
      with_redis do |redis|
        redis.sscan_each("chewy:queue:#{type.name}", count: SCAN_BATCH_SIZE).each_slice(IMPORT_BATCH_SIZE) do |ids|
          type.import!(ids)

          redis.srem("chewy:queue:#{type.name}", ids)
        end
      end
    end
  end

  private

  def indexes
    [AccountsIndex, TagsIndex, PublicStatusesIndex, StatusesIndex]
  end
end
