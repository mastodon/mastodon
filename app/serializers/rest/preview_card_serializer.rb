# frozen_string_literal: true

class REST::PreviewCardSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :url, :title, :description, :type,
             :author_name, :author_url, :provider_name,
             :provider_url, :html, :width, :height,
             :image

  def image
    object.image? ? full_asset_url(object.image.url(:original)) : nil
  end
end
