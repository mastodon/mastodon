class FixReblogsInFeeds < ActiveRecord::Migration[5.1]
  def up
    redis = Redis.current
    fm = FeedManager.instance

    # Old scheme:
    # Each user's feed zset had a series of score:value entries,
    # where "regular" statuses had the same score and value (their
    # ID). Reblogs had a score of the reblogging status' ID, and a
    # value of the reblogged status' ID.

    # New scheme:
    # The feed contains only entries with the same score and value.
    # Reblogs result in the reblogging status being added to the
    # feed, with an entry in a reblog tracking zset (where the score
    # is once again set to the reblogging status' ID, and the value
    # is set to the reblogged status' ID). This is safe for Redis'
    # float conversion because in this reblog tracking zset, we only
    # need the reblogging status' ID to be able to stop tracking
    # entries after they have gotten too far down the feed, which
    # does not require an exact value.

    # This process reads all feeds and writes 3 times for each reblogs.
    # So we use Lua script to avoid overhead between Ruby and Redis.
    script = <<-LUA
      local timeline_key = KEYS[1]
      local reblog_key = KEYS[2]

      -- So, first, we iterate over the user's feed to find any reblogs.
      local items = redis.call('zrange', timeline_key, 0, -1, 'withscores')

      for i = 1, #items, 2 do
        local reblogged_id = items[i]
        local reblogging_id = items[i + 1]
        if (reblogged_id ~= reblogging_id) then

          -- The score and value don't match, so this is a reblog.
          -- (note that we're transitioning from IDs < 53 bits so we
          -- don't have to worry about the loss of precision)

          -- Remove the old entry
          redis.call('zrem', timeline_key, reblogged_id)

          -- Add a new one for the reblogging status
          redis.call('zadd', timeline_key, reblogging_id, reblogging_id)

          -- Track the fact that this was a reblog
          redis.call('zadd', reblog_key, reblogging_id, reblogged_id)
        end
      end
    LUA
    script_hash = redis.script(:load, script)

    # find_each is batched on the database side.
    User.includes(:account).find_each do |user|
      account = user.account

      timeline_key = fm.key(:home, account.id)
      reblog_key = fm.key(:home, account.id, 'reblogs')

      redis.evalsha(script_hash, [timeline_key, reblog_key])
    end
  end

  def down
    # We *deliberately* do nothing here. This means that reverting
    # this and the associated changes to the FeedManager code could
    # allow one superfluous reblog of any given status, but in the case
    # where things have gone wrong and a revert is necessary, this
    # appears preferable to requiring a database hit for every status
    # in every users' feed simply to revert.

    # Note that this is operating under the assumption that entries
    # with >53-bit IDs have already been entered. Otherwise, we could
    # just use the data in Redis to reverse this transition.
  end
end
