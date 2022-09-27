# frozen_string_literal: true

class ActivityPub::GroupActorSerializer < ActivityPub::Serializer
  include RoutingHelper
  include FormattingHelper

  context :security

  context_extensions :discoverable, :suspended, :groups

  attributes :id, :type, :inbox, :outbox, :name, :url, :published, :wall, :members,
             :summary, :manually_approves_members, :attributed_to

  has_one :public_key, serializer: ActivityPub::PublicKeySerializer

  has_many :virtual_tags, key: :tag

  attribute :suspended, if: :suspended?

  class EndpointsSerializer < ActivityPub::Serializer
    include RoutingHelper

    attributes :shared_inbox

    def shared_inbox
      inbox_url
    end
  end

  has_one :endpoints, serializer: EndpointsSerializer

  has_one :icon,  serializer: ActivityPub::ImageSerializer, if: :avatar_exists?
  has_one :image, serializer: ActivityPub::ImageSerializer, if: :header_exists?

  delegate :suspended?, to: :object

  def id
    group_url(object)
  end

  def type
    'PublicGroup' # TODO
  end

  def wall
    group_wall_url(object)
  end

  def members
    group_members_url(object)
  end

  def inbox
    group_inbox_url(object)
  end

  def outbox
    group_outbox_url(object)
  end

  def endpoints
    object
  end

  def name
    object.suspended? ? '' : object.display_name
  end

  def summary
    object.suspended? ? '' : account_bio_format(object)
  end

  def manually_approves_members
    object.suspended? ? true : object.locked
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

  def suspended
    object.suspended?
  end

  def url
    group_url(object)
  end

  def avatar_exists?
    !object.suspended? && object.avatar?
  end

  def header_exists?
    !object.suspended? && object.header?
  end

  def virtual_tags
    object.suspended? ? [] : object.emojis
  end

  def published
    object.created_at.midnight.iso8601
  end

  def attributed_to
    object.memberships.includes(:account).where(role: [:admin, :moderator]).map { |membership| ActivityPub::TagManager.instance.uri_for(membership.account) }
  end

  class CustomEmojiSerializer < ActivityPub::EmojiSerializer
  end
end
