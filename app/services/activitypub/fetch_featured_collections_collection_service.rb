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

    items.take(MAX_ITEMS).each do |collection_json|
      if collection_json.is_a?(String)
        ActivityPub::FetchRemoteFeaturedCollectionService.new.call(collection_json, request_id: @request_id)
      else
        ActivityPub::ProcessFeaturedCollectionService.new.call(@account, collection_json, request_id: @request_id)
      end
    end
  end
end
