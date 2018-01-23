# frozen_string_literal: true

class PrecomputeFeedService < BaseService
  attr_reader :into_account

  def call(into_account)
    @into_account = into_account

    merge_own_timeline!
    merge_following_timelines!
    mark_finished!
  end

  private

  def merge_following_timelines!
    into_account.following.find_each { |from_account| FeedManager.instance.merge_into_timeline(from_account, into_account) }
  end

  def merge_own_timeline!
    FeedManager.instance.merge_into_timeline(into_account, into_account)
  end

  def mark_finished!
    Redis.current.del("account:#{into_account.id}:regeneration")
  end
end
