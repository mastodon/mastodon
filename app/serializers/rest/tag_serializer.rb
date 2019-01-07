# frozen_string_literal: true

class REST::TagSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :name, :url, :history

  def url
    tag_url(object)
  end
end
