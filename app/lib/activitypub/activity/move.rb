# frozen_string_literal: true

class ActivityPub::Activity::Move < ActivityPub::Activity
  PROCESSING_COOLDOWN = 7.days.seconds

  def perform
    return if origin_account.uri != object_uri
    return unless mark_as_processing!

    target_account = ActivityPub::FetchRemoteAccountService.new.call(target_uri)

    if target_account.nil? || target_account.unavailable? || !target_account.also_known_as.include?(origin_account.uri)
      unmark_as_processing!
      return
    end

    # In case for some reason we didn't have a redirect for the profile already, set it
    origin_account.update(moved_to_account: target_account)

    # Initiate a re-follow for each follower
    MoveWorker.perform_async(origin_account.id, target_account.id)
  rescue
    unmark_as_processing!
    raise
  end

  private

  def origin_account
    @account
  end

  def target_uri
    value_or_id(@json['target'])
  end

  def mark_as_processing!
    redis.set("move_in_progress:#{@account.id}", true, nx: true, ex: PROCESSING_COOLDOWN)
  end

  def unmark_as_processing!
    redis.del("move_in_progress:#{@account.id}")
  end
end
