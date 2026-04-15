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

        @collection.update!(collection_attributes)

        @items = (@json['orderedItems'] || [])[0, ITEMS_LIMIT]
        item_uris = @items.filter_map { |i| value_or_id(i) }
        @collection.collection_items.where.not(uri: item_uris).delete_all
      end

      process_items!
      notify_about_update!

      @collection
    end
  end

  private

  def notify_about_update!
    NotifyOfCollectionUpdateService.new.call(@collection)
  end

  def truncated_summary
    text = @json['summaryMap']&.values&.first || @json['summary'] || ''
    text[0, Collection::DESCRIPTION_LENGTH_HARD_LIMIT]
  end

  def language
    @json['summaryMap']&.keys&.first
  end

  def url
    url = url_to_href(@json['url'], 'text/html')
    return @json['id'] if url.blank? || unsupported_uri_scheme?(url)

    url
  end

  def collection_attributes
    {
      local: false,
      name: (@json['name'] || '')[0, Collection::NAME_LENGTH_HARD_LIMIT],
      description_html: truncated_summary,
      language:,
      sensitive: @json['sensitive'],
      discoverable: @json['discoverable'],
      original_number_of_items: @json['totalItems'] || 0,
      tag_name: @json.dig('topic', 'name'),
      url:,
    }
  end

  def process_items!
    @items.each_with_index do |item_json, index|
      ActivityPub::ProcessFeaturedItemWorker.perform_async(@collection.id, item_json, index + 1, @request_id)
    end
  end
end
