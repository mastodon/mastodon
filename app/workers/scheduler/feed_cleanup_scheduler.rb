# frozen_string_literal: true

class Scheduler::FeedCleanupScheduler
  include Sidekiq::Worker
  include Redisable

  sidekiq_options lock: :until_executed, retry: 0

  def perform
    clean_home_feeds!
    clean_list_feeds!
    clean_direct_feeds!
  end

  private

  def clean_home_feeds!
    feed_manager.clean_feeds!(:home, inactive_account_ids)
  end

  def clean_list_feeds!
    feed_manager.clean_feeds!(:list, inactive_list_ids)
  end

  def clean_direct_feeds!
    feed_manager.clean_feeds!(:direct, inactive_account_ids)
  end

  def inactive_account_ids
    @inactive_account_ids ||= User.confirmed.inactive.pluck(:account_id)
  end

  def inactive_list_ids
    List.where(account_id: inactive_account_ids).pluck(:id)
  end

  def feed_manager
    FeedManager.instance
  end
end
