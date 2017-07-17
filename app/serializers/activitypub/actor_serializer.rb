# frozen_string_literal: true

class ActivityPub::ActorSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :type, :following, :followers,
             :inbox, :outbox, :preferred_username,
             :name, :summary, :icon, :image, :url

  has_one :public_key, serializer: ActivityPub::PublicKeySerializer

  class ImageSerializer < ActiveModel::Serializer
    include RoutingHelper

    attributes :type, :url

    def type
      'Image'
    end

    def url
      full_asset_url(object.url(:original))
    end
  end

  has_one :icon,  serializer: ImageSerializer
  has_one :image, serializer: ImageSerializer

  def id
    account_url(object)
  end

  def type
    'Person'
  end

  def following
    account_following_index_url(object)
  end

  def followers
    account_followers_url(object)
  end

  def inbox
    account_inbox_url(object)
  end

  def outbox
    account_outbox_url(object)
  end

  def preferred_username
    object.username
  end

  def name
    object.display_name
  end

  def summary
    Formatter.instance.simplified_format(object)
  end

  def icon
    object.avatar
  end

  def image
    object.header
  end

  def public_key
    object
  end

  def url
    short_account_url(object)
  end
end
