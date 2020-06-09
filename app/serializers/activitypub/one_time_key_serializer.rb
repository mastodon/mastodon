# frozen_string_literal: true

class ActivityPub::OneTimeKeySerializer < ActivityPub::Serializer
  context :security

  context_extensions :olm

  class SignatureSerializer < ActivityPub::Serializer
    attributes :type, :signature_value

    def type
      'Ed25519Signature'
    end

    def signature_value
      object.signature
    end
  end

  attributes :key_id, :type, :public_key_base64

  has_one :signature, serializer: SignatureSerializer

  def type
    'Curve25519Key'
  end

  def public_key_base64
    object.key
  end

  def signature
    object
  end
end
