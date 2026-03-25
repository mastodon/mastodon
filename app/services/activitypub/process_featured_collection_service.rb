# frozen_string_literal: true

class ActivityPub::ProcessFeaturedCollectionService
  include JsonLdHelper
  include Lockable
  include Redisable

  ITEMS_LIMIT = 150

  def call(account, json, request_id: nil)
    @account = account
    @json = json
    @request_id = request_id
    return if non_matching_uri_hosts?(@account.uri, @json['id'])

    with_redis_lock("collection:#{@json['id']}") do
      Collection.transaction do
        @collection = @account.collections.find_or_initialize_by(uri: @json['id'])

        @collection.update!(
          local: false,
          name: (@json['name'] || '')[0, Collection::NAME_LENGTH_HARD_LIMIT],
          description_html: truncated_summary,
          language:,
          sensitive: @json['sensitive'],
          discoverable: @json['discoverable'],
          original_number_of_items: @json['totalItems'] || 0,
          tag_name: @json.dig('topic', 'name')
        )

        process_items!
      end

      @collection
    end
  end

  private

  def truncated_summary
    text = @json['summaryMap']&.values&.first || @json['summary'] || ''
    text[0, Collection::DESCRIPTION_LENGTH_HARD_LIMIT]
  end

  def language
    @json['summaryMap']&.keys&.first
  end

  def process_items!
    uris = []
    items = @json['orderedItems'] || []
    items.take(ITEMS_LIMIT).each_with_index do |item_json, index|
      uris << value_or_id(item_json)
      ActivityPub::ProcessFeaturedItemWorker.perform_async(@collection.id, item_json, index + 1, @request_id)
    end
    uris.compact!
    @collection.collection_items.where.not(uri: uris).delete_all
  end
end
