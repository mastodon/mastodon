# frozen_string_literal: true

class WebPushRequest
  SIGNATURE_ALGORITHM = 'p256ecdsa'
  LEGACY_AUTH_HEADER = 'WebPush'
  STANDARD_AUTH_HEADER = 'vapid'
  PAYLOAD_EXPIRATION = 24.hours
  JWT_ALGORITHM = 'ES256'
  JWT_TYPE = 'JWT'

  attr_reader :web_push_subscription

  delegate(
    :standard,
    :endpoint,
    :key_auth,
    :key_p256dh,
    to: :web_push_subscription
  )

  def initialize(web_push_subscription)
    @web_push_subscription = web_push_subscription
  end

  def audience
    @audience ||= Addressable::URI.parse(endpoint).normalized_site
  end

  def legacy_authorization_header
    [LEGACY_AUTH_HEADER, encoded_json_web_token].join(' ')
  end

  def crypto_key_header
    [SIGNATURE_ALGORITHM, vapid_key.public_key_for_push_header].join('=')
  end

  def legacy_encrypt(payload)
    Webpush::Legacy::Encryption.encrypt(payload, key_p256dh, key_auth)
  end

  def standard_authorization_header
    [STANDARD_AUTH_HEADER, standard_vapid_value].join(' ')
  end

  def standard_encrypt(payload)
    Webpush::Encryption.encrypt(payload, key_p256dh, key_auth)
  end

  def legacy
    !standard
  end

  private

  def standard_vapid_value
    "t=#{encoded_json_web_token},k=#{vapid_key.public_key_for_push_header}"
  end

  def encoded_json_web_token
    JWT.encode(
      web_token_payload,
      vapid_key.curve,
      JWT_ALGORITHM,
      typ: JWT_TYPE
    )
  end

  def web_token_payload
    {
      aud: audience,
      exp: PAYLOAD_EXPIRATION.from_now.to_i,
      sub: payload_subject,
    }
  end

  def payload_subject
    [:mailto, contact_email].join(':')
  end

  def vapid_key
    @vapid_key ||= Webpush::VapidKey.from_keys(
      Rails.configuration.x.vapid.public_key,
      Rails.configuration.x.vapid.private_key
    )
  end

  def contact_email
    @contact_email ||= ::Setting.site_contact_email
  end
end
