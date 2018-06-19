# frozen_string_literal: true

class ActivityPub::ActorSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :type, :following, :followers,
             :inbox, :outbox, :featured,
             :preferred_username, :name, :summary,
             :url, :manually_approves_followers

  has_one :public_key, serializer: ActivityPub::PublicKeySerializer

  has_many :virtual_tags, key: :tag
  has_many :virtual_attachments, key: :attachment

  attribute :moved_to, if: :moved?

  class EndpointsSerializer < ActiveModel::Serializer
    include RoutingHelper

    attributes :shared_inbox

    def shared_inbox
      inbox_url
    end
  end

  has_one :endpoints, serializer: EndpointsSerializer

  has_one :icon,  serializer: ActivityPub::ImageSerializer, if: :avatar_exists?
  has_one :image, serializer: ActivityPub::ImageSerializer, if: :header_exists?

  delegate :moved?, to: :object

  def id
    account_url(object)
  end

  def type
    object.bot? ? 'Service' : 'Person'
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

  def featured
    account_collection_url(object, :featured)
  end

  def endpoints
    object
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

  def avatar_exists?
    object.avatar.exists?
  end

  def header_exists?
    object.header.exists?
  end

  def manually_approves_followers
    object.locked
  end

  def virtual_tags
    object.emojis
  end

  def virtual_attachments
    object.fields
  end

  def moved_to
    ActivityPub::TagManager.instance.uri_for(object.moved_to_account)
  end

  class CustomEmojiSerializer < ActivityPub::EmojiSerializer
  end

  class Account::FieldSerializer < ActiveModel::Serializer
    attributes :type, :name, :value

    def type
      'PropertyValue'
    end

    def value
      Formatter.instance.format_field(object.account, object.value)
    end
  end
end
