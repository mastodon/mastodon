# frozen_string_literal: true

class REST::AccountFeaturedTagSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :name, :url

  def id
    object.tag.id.to_s
  end

  def name
    "##{object.name}"
  end

  def url
    short_account_tag_url(object.account, object.tag)
  end
end
