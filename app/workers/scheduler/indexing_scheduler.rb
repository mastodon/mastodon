# frozen_string_literal: true

class Scheduler::IndexingScheduler
  include Sidekiq::Worker
  include Redisable

  sidekiq_options retry: 0

  def perform
    indexes.each do |type|
      with_redis do |redis|
        ids = redis.smembers("chewy:queue:#{type.name}")

        type.import!(ids)

        redis.pipelined do |pipeline|
          ids.each { |id| pipeline.srem("chewy:queue:#{type.name}", id) }
        end
      end
    end
  end

  def indexes
    [AccountsIndex, TagsIndex, StatusesIndex]
  end
end
