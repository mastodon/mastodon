# frozen_string_literal: true

class REST::GroupSerializer < ActiveModel::Serializer
  include RoutingHelper
  include FormattingHelper

  attributes :id, :display_name, :created_at, :note, :uri, :url,
             :avatar, :avatar_static, :header, :header_static,
             :locked, :statuses_visibility, :membership_required,
             :note, :domain

  has_many :emojis, serializer: REST::CustomEmojiSerializer

  def id
    object.id.to_s
  end

  def note
    object.suspended? ? '' : account_bio_format(object)
  end

  def locked
    object.locked?
  end

  def url
    ActivityPub::TagManager.instance.url_for(object)
  end

  def uri
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def domain
    object.domain
  end

  def avatar
    full_asset_url(object.suspended? ? object.avatar.default_url : object.avatar_original_url)
  end

  def avatar_static
    full_asset_url(object.suspended? ? object.avatar.default_url : object.avatar_static_url)
  end

  def header
    full_asset_url(object.suspended? ? object.header.default_url : object.header_original_url)
  end

  def header_static
    full_asset_url(object.suspended? ? object.header.default_url : object.header_static_url)
  end

  def created_at
    object.created_at.midnight.as_json
  end

  def display_name
    object.suspended? ? '' : object.display_name
  end

  def emojis
    object.suspended? ? [] : object.emojis
  end

  def statuses_visibility
    'public'
  end

  def membership_required
    true
  end
end
