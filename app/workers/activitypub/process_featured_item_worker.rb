# frozen_string_literal: true

class ActivityPub::ProcessFeaturedItemWorker
  include Sidekiq::Worker
  include ExponentialBackoff

  sidekiq_options queue: 'pull', retry: 3

  def perform(collection_id, id_or_json, position = nil, request_id = nil)
    collection = Collection.find(collection_id)

    ActivityPub::ProcessFeaturedItemService.new.call(collection, id_or_json, position:, request_id:)
  rescue ActiveRecord::RecordNotFound
    true
  end
end
