# frozen_string_literal: true

class ActivityPub::VerifyFeaturedItemWorker
  include Sidekiq::Worker
  include ExponentialBackoff
  include JsonLdHelper

  sidekiq_options queue: 'pull', retry: 5

  def perform(collection_item_id, approval_uri, request_id = nil)
    collection_item = CollectionItem.find(collection_item_id)

    ActivityPub::VerifyFeaturedItemService.new.call(collection_item, approval_uri, request_id:)
  rescue ActiveRecord::RecordNotFound
    # Do nothing
    nil
  rescue Mastodon::UnexpectedResponseError => e
    raise e unless response_error_unsalvageable?(e.response)
  end
end
