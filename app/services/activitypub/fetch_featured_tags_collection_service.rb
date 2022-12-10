# frozen_string_literal: true

class ActivityPub::FetchFeaturedTagsCollectionService < BaseService
  include JsonLdHelper

  def call(account, url)
    return if url.blank? || account.suspended? || account.local?

    @account = account
    @json    = fetch_resource(url, true, local_follower)

    return unless supported_context?(@json)

    process_items(collection_items(@json))
  end

  private

  def collection_items(collection)
    all_items = []

    collection = fetch_collection(collection['first']) if collection['first'].present?

    while collection.is_a?(Hash)
      items = begin
        case collection['type']
        when 'Collection', 'CollectionPage'
          collection['items']
        when 'OrderedCollection', 'OrderedCollectionPage'
          collection['orderedItems']
        end
      end

      break if items.blank?

      all_items.concat(items)

      break if all_items.size >= FeaturedTag::LIMIT

      collection = collection['next'].present? ? fetch_collection(collection['next']) : nil
    end

    all_items
  end

  def fetch_collection(collection_or_uri)
    return collection_or_uri if collection_or_uri.is_a?(Hash)
    return if invalid_origin?(collection_or_uri)

    fetch_resource_without_id_validation(collection_or_uri, local_follower, true)
  end

  def process_items(items)
    names            = items.filter_map { |item| item['type'] == 'Hashtag' && item['name']&.delete_prefix('#') }.take(FeaturedTag::LIMIT)
    tags             = names.index_by { |name| HashtagNormalizer.new.normalize(name) }
    normalized_names = tags.keys

    FeaturedTag.includes(:tag).references(:tag).where(account: @account).where.not(tag: { name: normalized_names }).delete_all

    FeaturedTag.includes(:tag).references(:tag).where(account: @account, tag: { name: normalized_names }).each do |featured_tag|
      featured_tag.update(name: tags.delete(featured_tag.tag.name))
    end

    tags.each_value do |name|
      FeaturedTag.create!(account: @account, name: name)
    end
  end

  def local_follower
    return @local_follower if defined?(@local_follower)

    @local_follower = @account.followers.local.without_suspended.first
  end
end
