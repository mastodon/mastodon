# frozen_string_literal: true

class ActivityPub::FetchFeaturedCollectionService < BaseService
  include JsonLdHelper

  def call(account)
    return if account.featured_collection_url.blank? || account.suspended? || account.local?

    @account = account
    @json    = fetch_resource(@account.featured_collection_url, true)

    return unless supported_context?

    case @json['type']
    when 'Collection', 'CollectionPage'
      process_items @json['items']
    when 'OrderedCollection', 'OrderedCollectionPage'
      process_items @json['orderedItems']
    end
  end

  private

  def process_items(items)
    status_ids = items.map { |item| value_or_id(item) }
                      .reject { |uri| ActivityPub::TagManager.instance.local_uri?(uri) }
                      .filter_map { |uri| ActivityPub::FetchRemoteStatusService.new.call(uri) }
                      .select { |status| status.account_id == @account.id }
                      .map(&:id)

    to_remove = []
    to_add    = status_ids

    StatusPin.where(account: @account).pluck(:status_id).each do |status_id|
      if status_ids.include?(status_id)
        to_add.delete(status_id)
      else
        to_remove << status_id
      end
    end

    StatusPin.where(account: @account, status_id: to_remove).delete_all unless to_remove.empty?

    to_add.each do |status_id|
      StatusPin.create!(account: @account, status_id: status_id)
    end
  end

  def supported_context?
    super(@json)
  end
end
