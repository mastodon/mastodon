# frozen_string_literal: true

class ActivityPub::SynchronizeFeaturedCollectionWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', unique: :until_executed

  def perform(account_id)
    ActivityPub::FetchFeaturedCollectionService.new.call(Account.find(account_id))
  rescue ActiveRecord::RecordNotFound
    true
  end
end
