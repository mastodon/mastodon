class UnfollowService < BaseService
  # Unfollow and notify the remote user
  # @param [Account] source_account Where to unfollow from
  # @param [Account] target_account Which to unfollow
  def call(source_account, target_account)
    follow = source_account.unfollow!(target_account)
    NotificationWorker.perform_async(follow.stream_entry.id, target_account.id) unless target_account.local?
    unmerge_from_timeline(target_account, source_account)
  end

  private

  def unmerge_from_timeline(from_account, into_account)
    timeline_key = FeedManager.instance.key(:home, into_account.id)

    from_account.statuses.select('id').find_each do |status|
      redis.zrem(timeline_key, status.id)
    end

    FeedManager.instance.broadcast(into_account.id, type: 'unmerge')
  end

  def redis
    $redis
  end
end
