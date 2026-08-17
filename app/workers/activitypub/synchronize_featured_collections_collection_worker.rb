# frozen_string_literal: true

class ActivityPub::SynchronizeFeaturedCollectionsCollectionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', lock: :until_executed, lock_ttl: 1.day.to_i

  def perform(account_id, request_id = nil)
    account = Account.find(account_id)

    ActivityPub::FetchFeaturedCollectionsCollectionService.new.call(account, request_id:)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
