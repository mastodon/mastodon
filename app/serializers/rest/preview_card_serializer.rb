# frozen_string_literal: true

class REST::PreviewCardSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :url, :title, :description, :language, :type,
             :author_name, :author_url, :provider_name,
             :provider_url, :html, :width, :height,
             :image, :image_description, :embed_url, :blurhash, :published_at

  has_one :author_account, serializer: REST::AccountSerializer, if: -> { object.author_account.present? }

  def url
    object.original_url.presence || object.url
  end

  def image
    object.image? ? full_asset_url(object.image.url(:original)) : nil
  end

  def html
    Sanitize.fragment(object.html, Sanitize::Config::MASTODON_OEMBED)
  end
end
