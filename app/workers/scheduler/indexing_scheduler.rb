# frozen_string_literal: true

class Scheduler::IndexingScheduler
  include Sidekiq::Worker
  include Redisable

  sidekiq_options retry: 0

  IMPORT_BATCH_SIZE = 100
  SCAN_BATCH_SIZE = 100 * IMPORT_BATCH_SIZE

  def perform
    return unless Chewy.enabled?

    indexes.each do |type|
      with_redis do |redis|
        redis.sscan_each("chewy:queue:#{type.name}", count: SCAN_BATCH_SIZE).each_slice(IMPORT_BATCH_SIZE) do |ids|
          type.import!(ids)

          redis.pipelined do |pipeline|
            ids.each { |id| pipeline.srem("chewy:queue:#{type.name}", id) }
          end
        end
      end
    end
  end

  def indexes
    [AccountsIndex, TagsIndex, StatusesIndex]
  end
end
