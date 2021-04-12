# frozen_string_literal: true
# == Schema Information
#
# Table name: web_push_subscriptions
#
#  id              :bigint(8)        not null, primary key
#  endpoint        :string           not null
#  key_p256dh      :string           not null
#  key_auth        :string           not null
#  data            :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  access_token_id :bigint(8)
#  user_id         :bigint(8)
#

class Web::PushSubscription < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :access_token, class_name: 'Doorkeeper::AccessToken', optional: true

  has_one :session_activation, foreign_key: 'web_push_subscription_id', inverse_of: :web_push_subscription

  validates :endpoint, presence: true
  validates :key_p256dh, presence: true
  validates :key_auth, presence: true

  delegate :locale, to: :associated_user

  def encrypt(payload)
    Webpush::Encryption.encrypt(payload, key_p256dh, key_auth)
  end

  def audience
    @audience ||= Addressable::URI.parse(endpoint).normalized_site
  end

  def crypto_key_header
    p256ecdsa = vapid_key.public_key_for_push_header

    "p256ecdsa=#{p256ecdsa}"
  end

  def authorization_header
    jwt = JWT.encode({ aud: audience, exp: 24.hours.from_now.to_i, sub: "mailto:#{contact_email}" }, vapid_key.curve, 'ES256', typ: 'JWT')

    "WebPush #{jwt}"
  end

  def pushable?(notification)
    ActiveModel::Type::Boolean.new.cast(data&.dig('alerts', notification.type.to_s))
  end

  def associated_user
    return @associated_user if defined?(@associated_user)

    @associated_user = begin
      if user_id.nil?
        session_activation.user
      else
        user
      end
    end
  end

  def associated_access_token
    return @associated_access_token if defined?(@associated_access_token)

    @associated_access_token = begin
      if access_token_id.nil?
        find_or_create_access_token.token
      else
        access_token.token
      end
    end
  end

  class << self
    def unsubscribe_for(application_id, resource_owner)
      access_token_ids = Doorkeeper::AccessToken.where(application_id: application_id, resource_owner_id: resource_owner.id, revoked_at: nil).pluck(:id)
      where(access_token_id: access_token_ids).delete_all
    end
  end

  private

  def find_or_create_access_token
    Doorkeeper::AccessToken.find_or_create_for(
      application: Doorkeeper::Application.find_by(superapp: true),
      resource_owner: user_id || session_activation.user_id,
      scopes: Doorkeeper::OAuth::Scopes.from_string('read write follow push'),
      expires_in: Doorkeeper.configuration.access_token_expires_in,
      use_refresh_token: Doorkeeper.configuration.refresh_token_enabled?
    )
  end

  def vapid_key
    @vapid_key ||= Webpush::VapidKey.from_keys(Rails.configuration.x.vapid_public_key, Rails.configuration.x.vapid_private_key)
  end

  def contact_email
    @contact_email ||= ::Setting.site_contact_email
  end
end
