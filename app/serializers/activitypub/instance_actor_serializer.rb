# frozen_string_literal: true

class ActivityPub::InstanceActorSerializer < ActivityPub::Serializer
  include RoutingHelper

  context :security

  context_extensions :manually_approves_followers

  attributes :id, :type, :followers,
             :inbox,
             :preferred_username, :name, :summary,
             :url, :manually_approves_followers

  has_one :public_key, serializer: ActivityPub::PublicKeySerializer

  has_one :endpoints, serializer: ActivityPub::ActorSerializer::EndpointsSerializer

  has_one :icon,  serializer: ActivityPub::ImageSerializer, if: :avatar_exists?
  has_one :image, serializer: ActivityPub::ImageSerializer, if: :header_exists?

  delegate :summary, to: :object

  def id
    instance_actor_url
  end

  def type
    'Application'
  end

  def followers
    instance_actor_followers_url
  end

  def inbox
    instance_actor_inbox_url
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
    instance_actor_url
  end

  def avatar_exists?
    object.avatar?
  end

  def header_exists?
    object.header?
  end

  def manually_approves_followers
    object.locked
  end
end
