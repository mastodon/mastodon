# frozen_string_literal: true

class OAuthUserinfoSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :iss, :sub, :name, :preferred_username, :profile, :picture

  def iss
    root_url
  end

  def sub
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def name
    object.display_name
  end

  def preferred_username
    object.username
  end

  def profile
    ActivityPub::TagManager.instance.url_for(object)
  end

  def picture
    full_asset_url(object.avatar_original_url)
  end
end
