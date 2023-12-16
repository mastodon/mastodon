# frozen_string_literal: true

class ActivityPub::FetchFeaturedCollectionService < BaseService
  include JsonLdHelper

  def call(account, **options)
    return if account.featured_collection_url.blank? || account.suspended? || account.local?

    @account = account
    @options = options
    @json    = fetch_resource(@account.featured_collection_url, true, local_follower)

    return unless supported_context?(@json)

    process_items(collection_items(@json))
  end

  private

  def collection_items(collection)
    collection = fetch_collection(collection['first']) if collection['first'].present?
    return unless collection.is_a?(Hash)

    case collection['type']
    when 'Collection', 'CollectionPage'
      collection['items']
    when 'OrderedCollection', 'OrderedCollectionPage'
      collection['orderedItems']
    end
  end

  def fetch_collection(collection_or_uri)
    return collection_or_uri if collection_or_uri.is_a?(Hash)
    return if invalid_origin?(collection_or_uri)

    fetch_resource_without_id_validation(collection_or_uri, local_follower, true)
  end

  def process_items(items)
    process_note_items(items) if @options[:note]
    process_hashtag_items(items) if @options[:hashtag]
  end

  def process_note_items(items)
    status_ids = items.filter_map do |item|
      next unless item.is_a?(String) || item['type'] == 'Note'

      uri = value_or_id(item)
      next if ActivityPub::TagManager.instance.local_uri?(uri) || invalid_origin?(uri)

      status = ActivityPub::FetchRemoteStatusService.new.call(uri, on_behalf_of: local_follower, expected_actor_uri: @account.uri, request_id: @options[:request_id])
      next unless status&.account_id == @account.id

      status.id
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.debug { "Invalid pinned status #{uri}: #{e.message}" }
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

  def process_hashtag_items(items)
    names     = items.filter_map { |item| item['type'] == 'Hashtag' && item['name']&.delete_prefix('#') }.map { |name| HashtagNormalizer.new.normalize(name) }
    to_remove = []
    to_add    = names

    FeaturedTag.where(account: @account).map(&:name).each do |name|
      if names.include?(name)
        to_add.delete(name)
      else
        to_remove << name
      end
    end

    FeaturedTag.includes(:tag).where(account: @account, tags: { name: to_remove }).delete_all unless to_remove.empty?

    to_add.each do |name|
      FeaturedTag.create!(account: @account, name: name)
    end
  end

  def local_follower
    return @local_follower if defined?(@local_follower)

    @local_follower = @account.followers.local.without_suspended.first
  end
end
