# frozen_string_literal: true

class ActivityPub::VerifyFeaturedItemWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 5

  def perform(collection_item_id)
    collection_item = CollectionItem.find(collection_item_id)

    ActivityPub::VerifyFeaturedItemService.new.call(collection_item)
  rescue ActiveRecord::RecordNotFound
    # Do nothing
    nil
  rescue Mastodon::UnexpectedResponseError => e
    raise e unless response_error_unsalvageable?(e.response)
  end
end
