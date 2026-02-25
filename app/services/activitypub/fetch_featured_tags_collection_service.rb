# frozen_string_literal: true

class ActivityPub::FetchFeaturedTagsCollectionService < BaseService
  include JsonLdHelper

  def call(account, url)
    return if url.blank? || account.suspended? || account.local?

    @account = account
    @json    = fetch_resource(url, true, local_follower)

    return unless supported_context?(@json)

    @items, = collection_items(@json, max_items: FeaturedTag::LIMIT, max_pages: FeaturedTag::LIMIT, reference_uri: @account.uri, on_behalf_of: local_follower)
    process_items(@items)
  end

  private

  def process_items(items)
    return if items.nil?

    names            = items.filter_map { |item| item['type'] == 'Hashtag' && item['name']&.delete_prefix('#') }.take(FeaturedTag::LIMIT)
    tags             = names.index_by { |name| HashtagNormalizer.new.normalize(name) }
    normalized_names = tags.keys

    FeaturedTag.includes(:tag).references(:tag).where(account: @account).where.not(tag: { name: normalized_names }).delete_all

    FeaturedTag.includes(:tag).references(:tag).where(account: @account, tag: { name: normalized_names }).find_each do |featured_tag|
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
