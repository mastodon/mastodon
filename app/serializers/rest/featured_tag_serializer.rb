# frozen_string_literal: true

class REST::FeaturedTagSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :name, :url, :statuses_count, :last_status_at

  def id
    object.id.to_s
  end

  def url
    # The path is hardcoded because we have to deal with both local and
    # remote users, which are different routes
    account_with_domain_url(object.account, "tagged/#{object.tag.to_param}")
  end

  def name
    object.display_name
  end

  def statuses_count
    object.statuses_count.to_s
  end

  def last_status_at
    object.last_status_at&.to_date&.iso8601
  end
end
