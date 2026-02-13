# frozen_string_literal: true

class ThreadRepair
  include Redisable

  THREAD_FIXUP_WINDOW = 1.hour.to_i

  def initialize(parent_uri)
    @parent_uri = parent_uri
  end

  def find_parent(child_id)
    with_redis do |redis|
      redis.sadd(redis_key, child_id)
      redis.expire(redis_key, THREAD_FIXUP_WINDOW)

      parent = ActivityPub::TagManager.instance.uri_to_resource(@parent_uri, Status)
      redis.srem(redis_key, child_id) if parent.present?

      parent
    end
  end

  def reattach_orphaned_children!(parent)
    with_redis do |redis|
      redis.sscan_each(redis_key, count: 1000) do |ids|
        statuses = Status.where(id: ids).to_a

        statuses.each { |status| status.update(thread: parent) }

        # Updated statuses need to be distributed to clients/inserted in TLs
        DistributionWorker.push_bulk(statuses.filter(&:within_realtime_window?)) do |status|
          [status.id, { 'skip_notifications' => true }]
        end

        redis.srem(redis_key, ids)
      end
    end
  end

  def redis_key
    "thread_repair:#{@parent_uri}"
  end
end
