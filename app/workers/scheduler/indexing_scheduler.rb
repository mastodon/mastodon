# frozen_string_literal: true

class Scheduler::IndexingScheduler
  include Sidekiq::Worker
  include Redisable

  sidekiq_options retry: 0

  IMPORT_BATCH_SIZE = 1000
  SCAN_BATCH_SIZE = 10 * IMPORT_BATCH_SIZE

  def perform
    return unless Chewy.enabled?

    indexes.each do |type|
      with_redis do |redis|
        redis.sscan_each("chewy:queue:#{type.name}", count: SCAN_BATCH_SIZE) do |ids|
          redis.pipelined do
            ids.each_slice(IMPORT_BATCH_SIZE) do |slice_ids|
              type.import!(slice_ids)
              redis.srem("chewy:queue:#{type.name}", slice_ids)
            end
          end
        end
      end
    end
  end

  def indexes
    [AccountsIndex, TagsIndex, StatusesIndex]
  end
end
