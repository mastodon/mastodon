# frozen_string_literal: true

class ActivityPub::PublicKeySerializer < ActivityPub::Serializer
  context :security

  attributes :id, :owner, :public_key_pem

  def id
    [ActivityPub::TagManager.instance.uri_for(object), '#main-key'].join
  end

  def owner
    ActivityPub::TagManager.instance.uri_for(object)
  end

  def public_key_pem
    object.public_key
  end
end
