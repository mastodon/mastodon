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
          },
        }
      ),
      endpoint: endpoint,
      p256dh: key_p256dh,
      auth: key_auth,
      vapid: {
        private_key: Redis.current.get('vapid_private_key'),
        public_key: Redis.current.get('vapid_public_key'),
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
    when :follow_request then translate('push_notifications.follow_request.title', name: name)
    when :favourite then translate('push_notifications.favourite.title', name: name)
    when :reblog then translate('push_notifications.reblog.title', name: name)
    end
  end

  def body_str(notification)
    case notification.type
    when :mention then notification.target_status.text
    when :follow then notification.from_account.note
    when :follow_request then notification.from_account.note
    when :favourite then notification.target_status.text
    when :reblog then notification.target_status.text
    end
  end

  def url_str(notification)
    case notification.type
    when :mention then web_url("statuses/#{notification.target_status.id}")
    when :follow then web_url("accounts/#{notification.follow.id}")
    when :follow_request then web_url('follow_requests')
    when :favourite then web_url("statuses/#{notification.target_status.id}")
    when :reblog then web_url("statuses/#{notification.target_status.id}")
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
          data: {
            url: web_url('notifications'),
          },
        }
      ),
      endpoint: endpoint,
      p256dh: key_p256dh,
      auth: key_auth,
      vapid: {
        private_key: Redis.current.get('vapid_private_key'),
        public_key: Redis.current.get('vapid_public_key'),
      }
    )
  end
end
