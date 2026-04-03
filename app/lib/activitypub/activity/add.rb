# frozen_string_literal: true

class ActivityPub::Activity::Add < ActivityPub::Activity
  def perform
    return if @json['target'].blank?

    case value_or_id(@json['target'])
    when @account.featured_collection_url
      case @object['type']
      when 'Hashtag'
        add_featured_tags
      else
        add_featured
      end
    when @account.collections_url
      return unless Mastodon::Feature.collections_enabled?

      add_collection
    else
      return unless Mastodon::Feature.collections_enabled?

      @collection = @account.collections.find_by(uri: value_or_id(@json['target']))
      if @collection.present?
        add_collection_item
      else
        # At this point we do not know and cannot handle the target.
        # This can have any number of reasons but for a while after
        # FeaturedCollections are introduced it might be because the
        # account data is stale. Instead of updating the account, which
        # is very expensive, we attempt to only detect if this is the case
        # with the least amount of effort possible.
        # Can be removed once Mastodon 4.6 or later has been deployed on
        # a sufficiently large number of servers.
        attempt_bootstrapping_collections
      end
    end
  end

  private

  def add_featured
    status = status_from_object

    return unless !status.nil? && status.account_id == @account.id && !@account.pinned?(status)

    StatusPin.create!(account: @account, status: status)
  end

  def add_featured_tags
    name = @object['name']&.delete_prefix('#')

    FeaturedTag.create!(account: @account, name: name) if name.present?
  end

  def add_collection
    ActivityPub::ProcessFeaturedCollectionService.new.call(@account, @object)
  end

  def add_collection_item
    ActivityPub::ProcessFeaturedItemService.new.call(@collection, @object)
  end

  def attempt_bootstrapping_collections
    return if @account.collections_url.present?

    actor_json = fetch_resource(@account.uri, true)
    if actor_json && actor_json['featuredCollections'].present?
      @account.update!(collections_url: actor_json['featuredCollections'])
      ActivityPub::SynchronizeFeaturedCollectionsCollectionWorker.perform_async(@account.id)
    end
  end
end
