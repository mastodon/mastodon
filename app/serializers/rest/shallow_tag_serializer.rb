# frozen_string_literal: true

class REST::ShallowTagSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :name, :url

  def url
    tag_url(object)
  end
end
