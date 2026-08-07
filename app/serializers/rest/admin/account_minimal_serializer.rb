# frozen_string_literal: true

class REST::Admin::AccountMinimalSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :username, :acct, :display_name, :uri, :url, :avatar, :avatar_static

  def id
    object.id.to_s
  end

  def acct
    object.pretty_acct
  end

  def url
    ActivityPub::TagManager.instance.url_for(object)
  end

  def uri
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def avatar
    full_asset_url(object.unavailable? ? object.avatar.default_url : object.avatar_original_url)
  end

  def avatar_static
    full_asset_url(object.unavailable? ? object.avatar.default_url : object.avatar_static_url)
  end
end
