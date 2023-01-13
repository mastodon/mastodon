# frozen_string_literal: true

class ActivityPub::Activity::Remove < ActivityPub::Activity
  def perform
    return if @json['target'].blank?

    case value_or_id(@json['target'])
    when @account.featured_collection_url
      case @object['type']
      when 'Hashtag'
        remove_featured_tags
      else
        remove_featured
      end
    end
  end

  private

  def remove_featured
    status = status_from_uri(object_uri)

    return unless !status.nil? && status.account_id == @account.id

    pin = StatusPin.find_by(account: @account, status: status)
    pin&.destroy!
  end

  def remove_featured_tags
    name = @object['name']&.delete_prefix('#')

    return if name.blank?

    featured_tag = FeaturedTag.by_name(name).find_by(account: @account)
    featured_tag&.destroy!
  end
end
