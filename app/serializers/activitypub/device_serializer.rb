# frozen_string_literal: true

class ActivityPub::DeviceSerializer < ActivityPub::Serializer
  context_extensions :olm

  include RoutingHelper

  class FingerprintKeySerializer < ActivityPub::Serializer
    attributes :type, :public_key_base64

    def type
      'Ed25519Key'
    end

    def public_key_base64
      object.fingerprint_key
    end
  end

  class IdentityKeySerializer < ActivityPub::Serializer
    attributes :type, :public_key_base64

    def type
      'Curve25519Key'
    end

    def public_key_base64
      object.identity_key
    end
  end

  attributes :device_id, :type, :name, :claim

  has_one :fingerprint_key, serializer: FingerprintKeySerializer
  has_one :identity_key, serializer: IdentityKeySerializer

  def type
    'Device'
  end

  def claim
    account_claim_url(object.account, id: object.device_id)
  end

  def fingerprint_key
    object
  end

  def identity_key
    object
  end
end
