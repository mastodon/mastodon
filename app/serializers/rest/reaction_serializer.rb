# frozen_string_literal: true

class REST::ReactionSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :name, :count

  attribute :me, if: :current_user?
  attribute :url, if: :custom_emoji?
  attribute :static_url, if: :custom_emoji?

  def count
    object.respond_to?(:count) ? object.count : 0
  end

  def current_user?
    !current_user.nil?
  end

  def custom_emoji?
    object.custom_emoji.present?
  end

  def url
    full_asset_url(object.custom_emoji.image.url)
  end

  def static_url
    full_asset_url(object.custom_emoji.image.url(:static))
  end
end
