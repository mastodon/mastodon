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
require_relative '../../models/setting'

class Web::PushSubscription < ApplicationRecord
  include RoutingHelper
  include StreamEntriesHelper
  include ActionView::Helpers::TranslationHelper
  include ActionView::Helpers::SanitizeHelper

  has_one :session_activation

  before_create :send_welcome_notification

  def push(notification)
    name = display_name notification.from_account
    title = title_str(name, notification)
    body = body_str notification
    dir = dir_str body
    url = url_str notification
    image = image_str notification
    actions = actions_arr notification

    access_token = actions.empty? ? nil : find_or_create_access_token(notification).token
    nsfw = notification.target_status.nil? || notification.target_status.spoiler_text.empty? ? nil : notification.target_status.spoiler_text

    # TODO: Make sure that the payload does not exceed 4KB - Webpush::PayloadTooLarge
    Webpush.payload_send(
      message: JSON.generate(
        title: title,
        dir: dir,
        image: image,
        badge: full_asset_url('badge.png', skip_pipeline: true),
        tag: notification.id,
        timestamp: notification.created_at,
        icon: notification.from_account.avatar_static_url,
        data: {
          content: decoder.decode(strip_tags(body)),
          nsfw: nsfw.nil? ? nil : decoder.decode(strip_tags(nsfw)),
          url: url,
          actions: actions,
          access_token: access_token,
          message: translate('push_notifications.group.title'), # Do not pass count, will be formatted in the ServiceWorker
        }
      ),
      endpoint: endpoint,
      p256dh: key_p256dh,
      auth: key_auth,
      vapid: {
        subject: "mailto:#{Setting.site_contact_email}",
        private_key: Rails.configuration.x.vapid_private_key,
        public_key: Rails.configuration.x.vapid_public_key,
      },
      ttl: 40 * 60 * 60 # 48 hours
    )
  end

  def pushable?(notification)
    data && data.key?('alerts') && data['alerts'][notification.type.to_s]
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
    actions =
      case notification.type
      when :mention then [
        {
          title: translate('push_notifications.mention.action_favourite'),
          icon: full_asset_url('web-push-icon_favourite.png', skip_pipeline: true),
          todo: 'request',
          method: 'POST',
          action: "/api/v1/statuses/#{notification.target_status.id}/favourite",
        },
      ]
      else []
      end

    should_hide = notification.type.equal?(:mention) && !notification.target_status.nil? && (notification.target_status.sensitive || !notification.target_status.spoiler_text.empty?)
    can_boost = notification.type.equal?(:mention) && !notification.target_status.nil? && !notification.target_status.hidden?

    if should_hide
      actions.insert(0, title: translate('push_notifications.mention.action_expand'), icon: full_asset_url('web-push-icon_expand.png', skip_pipeline: true), todo: 'expand', action: 'expand')
    end

    if can_boost
      actions << { title: translate('push_notifications.mention.action_boost'), icon: full_asset_url('web-push-icon_reblog.png', skip_pipeline: true), todo: 'request', method: 'POST', action: "/api/v1/statuses/#{notification.target_status.id}/reblog" }
    end

    actions
  end

  def image_str(notification)
    return nil if notification.target_status.nil? || notification.target_status.media_attachments.empty?

    full_asset_url(notification.target_status.media_attachments.first.file.url(:small))
  end

  def dir_str(body)
    rtl?(body) ? 'rtl' : 'ltr'
  end

  def send_welcome_notification
    Webpush.payload_send(
      message: JSON.generate(
        title: translate('push_notifications.subscribed.title'),
        icon: full_asset_url('android-chrome-192x192.png', skip_pipeline: true),
        badge: full_asset_url('badge.png', skip_pipeline: true),
        data: {
          content: translate('push_notifications.subscribed.body'),
          actions: [],
          url: web_url('notifications'),
          message: translate('push_notifications.group.title'), # Do not pass count, will be formatted in the ServiceWorker
        }
      ),
      endpoint: endpoint,
      p256dh: key_p256dh,
      auth: key_auth,
      vapid: {
        subject: "mailto:#{Setting.site_contact_email}",
        private_key: Rails.configuration.x.vapid_private_key,
        public_key: Rails.configuration.x.vapid_public_key,
      },
      ttl: 5 * 60 # 5 minutes
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

  def decoder
    @decoder ||= HTMLEntities.new
  end
end
