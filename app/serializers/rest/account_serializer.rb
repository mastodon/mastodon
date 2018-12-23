# frozen_string_literal: true

class REST::AccountSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :username, :acct, :display_name, :locked, :created_at,
             :note, :url, :avatar, :avatar_static, :header, :header_static,
             :followers_count, :following_count, :statuses_count

  def id
    object.id.to_s
  end

  def note
    Formatter.instance.simplified_format(object)
  end

  def url
    TagManager.instance.url_for(object)
  end

  def avatar
    full_asset_url(object.avatar_original_url)
  end

  def avatar_static
    full_asset_url(object.avatar_static_url)
  end

  def header
    full_asset_url(object.header_original_url)
  end

  def header_static
    full_asset_url(object.header_static_url)
  end
end
