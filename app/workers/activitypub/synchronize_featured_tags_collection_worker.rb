# frozen_string_literal: true

class ActivityPub::SynchronizeFeaturedTagsCollectionWorker < ApplicationWorker
  sidekiq_options queue: 'pull', lock: :until_executed, lock_ttl: 1.day.to_i

  def perform(account_id, url)
    ActivityPub::FetchFeaturedTagsCollectionService.new.call(Account.find(account_id), url)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
