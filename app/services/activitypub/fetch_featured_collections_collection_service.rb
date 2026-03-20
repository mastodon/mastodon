# frozen_string_literal: true

class ActivityPub::FetchFeaturedCollectionsCollectionService < BaseService
  include JsonLdHelper

  MAX_PAGES = 10
  MAX_ITEMS = 50

  def call(account, request_id: nil)
    return if account.collections_url.blank? || account.suspended? || account.local?

    @request_id = request_id
    @account = account
    @items, = collection_items(@account.collections_url, max_pages: MAX_PAGES, reference_uri: @account.uri)
    process_items(@items)
  end

  private

  def process_items(items)
    return if items.nil?

    process_service = ActivityPub::ProcessFeaturedCollectionService.new
    fetch_service = ActivityPub::FetchRemoteFeaturedCollectionService.new

    items.take(MAX_ITEMS).each do |collection_json|
      if collection_json.is_a?(String)
        fetch_service.call(collection_json, request_id: @request_id)
      else
        process_service.call(@account, collection_json, request_id: @request_id)
      end
    end
  end
end
