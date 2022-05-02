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
    status_ids = items.filter_map do |item|
      uri = value_or_id(item)
      next if ActivityPub::TagManager.instance.local_uri?(uri)

      status = ActivityPub::FetchRemoteStatusService.new.call(uri, on_behalf_of: local_follower)
      next unless status&.account_id == @account.id

      status.id
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.debug "Invalid pinned status #{uri}: #{e.message}"
      nil
    end

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

  def local_follower
    return @local_follower if defined?(@local_follower)

    @local_follower = @account.followers.local.without_suspended.first
  end
end
