# frozen_string_literal: true

class REST::PreviewCardSerializer < ActiveModel::Serializer
  class AuthorSerializer < ActiveModel::Serializer
    attributes :name, :url
    has_one :account, serializer: REST::AccountSerializer
  end

  include RoutingHelper

  attributes :url, :title, :description, :language, :type,
             :author_name, :author_url, :provider_name,
             :provider_url, :html, :width, :height,
             :image, :image_description, :embed_url, :blurhash, :published_at

  has_many :authors, serializer: AuthorSerializer

  attribute :missing_attribution, if: :current_user?

  def url
    object.original_url.presence || object.url
  end

  def image
    object.image? ? full_asset_url(object.image.url(:original)) : nil
  end

  def html
    Sanitize.fragment(object.html, Sanitize::Config::MASTODON_OEMBED)
  end

  def missing_attribution
    object.unverified_author_account_id.present? && object.unverified_author_account_id == current_user.account_id
  end

  def current_user?
    !current_user.nil?
  end
end
