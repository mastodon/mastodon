# frozen_string_literal: true

class ActivityPub::BareActorSerializer < ActivityPub::Serializer
  include RoutingHelper

  context :security

  attributes :id, :type, :inbox

  has_one :public_key, serializer: ActivityPub::PublicKeySerializer
  has_one :endpoints, serializer: ActivityPub::ActorSerializer::EndpointsSerializer

  def id
    account_url(object)
  end

  def type
    object.bot? ? 'Service' : 'Person'
  end

  def inbox
    account_inbox_url(object)
  end

  def endpoints
    object
  end

  def preferred_username
    object.username
  end

  def public_key
    object
  end
end
