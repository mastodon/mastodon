# frozen_string_literal: true
# == Schema Information
#
# Table name: web_push_subscriptions
#
#  id         :integer          not null, primary key
#  endpoint   :string           not null
#  key_p256dh :string           not null
#  key_auth   :string           not null
#  data       :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'webpush'

class Web::PushSubscription < ApplicationRecord
  has_one :session_activation

  def push(notification)
    I18n.with_locale(session_activation.user.locale || I18n.default_locale) do
      push_payload(message_from(notification), 48.hours.seconds)
    end
  end

  def pushable?(notification)
    data && data.key?('alerts') && data['alerts'][notification.type.to_s]
  end

  def as_payload
    payload = { id: id, endpoint: endpoint }
    payload[:alerts] = data['alerts'] if data && data.key?('alerts')
    payload
  end

  def access_token
    find_or_create_access_token.token
  end

  private

  def push_payload(message, ttl = 5.minutes.seconds)
    # TODO: Make sure that the payload does not
    # exceed 4KB - Webpush::PayloadTooLarge

    Webpush.payload_send(
      message: Oj.dump(message),
      endpoint: endpoint,
      p256dh: key_p256dh,
      auth: key_auth,
      ttl: ttl,
      vapid: {
        subject: "mailto:#{::Setting.site_contact_email}",
        private_key: Rails.configuration.x.vapid_private_key,
        public_key: Rails.configuration.x.vapid_public_key,
      }
    )
  end

  def message_from(notification)
    serializable_resource = ActiveModelSerializers::SerializableResource.new(notification, serializer: Web::NotificationSerializer, scope: self, scope_name: :current_push_subscription)
    serializable_resource.as_json
  end

  def find_or_create_access_token
    Doorkeeper::AccessToken.find_or_create_for(
      Doorkeeper::Application.find_by(superapp: true),
      session_activation.user_id,
      Doorkeeper::OAuth::Scopes.from_string('read write follow'),
      Doorkeeper.configuration.access_token_expires_in,
      Doorkeeper.configuration.refresh_token_enabled?
    )
  end
end
