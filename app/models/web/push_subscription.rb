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

  has_one :session_activation

  def push(notification)
    I18n.with_locale(associated_user&.locale || I18n.default_locale) do
      push_payload(payload_for_notification(notification), 48.hours.seconds)
    end
  end

  def pushable?(notification)
    data&.key?('alerts') && ActiveModel::Type::Boolean.new.cast(data['alerts'][notification.type.to_s])
  end

  def associated_user
    return @associated_user if defined?(@associated_user)

    @associated_user = if user_id.nil?
                         session_activation.user
                       else
                         user
                       end
  end

  def associated_access_token
    return @associated_access_token if defined?(@associated_access_token)

    @associated_access_token = if access_token_id.nil?
                                 find_or_create_access_token.token
                               else
                                 access_token.token
                               end
  end

  class << self
    def unsubscribe_for(application_id, resource_owner)
      access_token_ids = Doorkeeper::AccessToken.where(application_id: application_id, resource_owner_id: resource_owner.id, revoked_at: nil)
                                                .pluck(:id)

      where(access_token_id: access_token_ids).delete_all
    end
  end

  private

  def push_payload(message, ttl = 5.minutes.seconds)
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

  def payload_for_notification(notification)
    ActiveModelSerializers::SerializableResource.new(
      notification,
      serializer: Web::NotificationSerializer,
      scope: self,
      scope_name: :current_push_subscription
    ).as_json
  end

  def find_or_create_access_token
    Doorkeeper::AccessToken.find_or_create_for(
      Doorkeeper::Application.find_by(superapp: true),
      session_activation.user_id,
      Doorkeeper::OAuth::Scopes.from_string('read write follow push'),
      Doorkeeper.configuration.access_token_expires_in,
      Doorkeeper.configuration.refresh_token_enabled?
    )
  end
end
