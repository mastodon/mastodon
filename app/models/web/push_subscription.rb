# frozen_string_literal: true
# == Schema Information
#
# Table name: web_push_subscriptions
#
#  id         :integer          not null, primary key
#  endpoint   :string
#  key_p256dh :string
#  key_auth   :string
#  data       :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Web::PushSubscription < ApplicationRecord
  include RoutingHelper
  include StreamEntriesHelper
  include ActionView::Helpers::TranslationHelper

  has_one :session_activation

  before_create :send_welcome_notification

  def push(notification)
    return unless pushable? notification

    name = display_name notification.from_account
    title = title_str(name, notification)
    body = body_str notification
    dir = dir_str body
    url = url_str notification
    image = image_str notification
    actions = actions_arr notification

    access_token = actions.empty? ? nil : find_or_create_access_token(notification).token

    Webpush.payload_send(
      message: JSON.generate(
        title: title,
        options: {
          body: body,
          dir: dir,
          image: image,
          tag: notification.id,
          timestamp: notification.created_at,
          icon: notification.from_account.avatar_static_url,
          data: {
            url: url,
            actions: actions,
            access_token: access_token,
          },
        }
      ),
      endpoint: endpoint,
      p256dh: key_p256dh,
      auth: key_auth,
      vapid: {
        subject: "mailto:#{Setting.site_contact_email}",
        private_key: Rails.configuration.x.vapid_private_key,
        public_key: Rails.configuration.x.vapid_public_key,
      }
    )
  end

  def as_payload
    payload = {
      id: id,
      endpoint: endpoint,
    }

    payload[:alerts] = data['alerts'] if data && data.key?('alerts')

    payload
  end

  private

  def title_str(name, notification)
    case notification.type
    when :mention then translate('push_notifications.mention.title', name: name)
    when :follow then translate('push_notifications.follow.title', name: name)
    when :favourite then translate('push_notifications.favourite.title', name: name)
    when :reblog then translate('push_notifications.reblog.title', name: name)
    end
  end

  def body_str(notification)
    case notification.type
    when :mention then notification.target_status.text
    when :follow then notification.from_account.note
    when :favourite then notification.target_status.text
    when :reblog then notification.target_status.text
    end
  end

  def url_str(notification)
    case notification.type
    when :mention then web_url("statuses/#{notification.target_status.id}")
    when :follow then web_url("accounts/#{notification.from_account.id}")
    when :favourite then web_url("statuses/#{notification.target_status.id}")
    when :reblog then web_url("statuses/#{notification.target_status.id}")
    end
  end

  def actions_arr(notification)
    case notification.type
    when :mention then [
      {
        title: translate('push_notifications.mention.action_favourite'),
        icon: full_asset_url('emoji/2764.png'),
        type: 'request',
        method: 'POST',
        action: "/api/v1/statuses/#{notification.target_status.id}/favourite",
      },
      {
        title: translate('push_notifications.mention.action_boost'),
        icon: full_asset_url('emoji/1f504.png'),
        type: 'request',
        method: 'POST',
        action: "/api/v1/statuses/#{notification.target_status.id}/reblog",
      },
    ]
    else []
    end
  end

  def image_str(notification)
    return nil if notification.target_status.nil? || notification.target_status.media_attachments.empty?

    full_asset_url(notification.target_status.media_attachments.first.file.url(:small))
  end

  def dir_str(body)
    rtl?(body) ? 'rtl' : 'ltr'
  end

  def pushable?(notification)
    data && data.key?('alerts') && data['alerts'][notification.type.to_s]
  end

  def send_welcome_notification
    Webpush.payload_send(
      message: JSON.generate(
        title: translate('push_notifications.subscribed.title'),
        options: {
          body: translate('push_notifications.subscribed.body'),
          icon: full_asset_url('android-chrome-192x192.png'),
          data: {
            url: web_url('notifications'),
          },
        }
      ),
      endpoint: endpoint,
      p256dh: key_p256dh,
      auth: key_auth,
      vapid: {
        subject: "mailto:#{Setting.site_contact_email}",
        private_key: Rails.configuration.x.vapid_private_key,
        public_key: Rails.configuration.x.vapid_public_key,
      }
    )
  end

  def find_or_create_access_token(notification)
    Doorkeeper::AccessToken.find_or_create_for(
      Doorkeeper::Application.find_by(superapp: true),
      notification.account.user.id,
      Doorkeeper::OAuth::Scopes.from_string('read write follow'),
      Doorkeeper.configuration.access_token_expires_in,
      Doorkeeper.configuration.refresh_token_enabled?
    )
  end
end
