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
      @collection = @account.collections.find_by(uri: value_or_id(@json['target']))
      add_collection_item if @collection && Mastodon::Feature.collections_enabled?
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
end
