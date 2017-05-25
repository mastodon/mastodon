# == Schema Information
#
# Table name: web_push_subscriptions
#
#  id         :integer          not null, primary key
#  account_id :integer
#  endpoint   :string
#  key_p256dh :string
#  key_auth   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WebPushSubscription < ApplicationRecord
  include RoutingHelper

  def push(notification)
    begin
      # TODO: Why is notification.from_account.hub_url nil?
      name = if notification.from_account.display_name.empty? then
               "#{notification.from_account.username}@#{notification.from_account.hub_url}"
             else
               notification.from_account.display_name
             end

      # TODO: Move somewhere else
      titles = {
        'Mention' => "#{name} mentioned you",
        'Follow' => "#{name} followed you",
        'FollowRequest' => "#{name} requested to follow you",
        'Favourite' => "#{name} favourited your status",
        'Status' => "#{name} boosted your status",
      }

      title = titles[notification.activity_type]
      url = case notification.activity_type
              when 'Mention' then web_url("statuses/#{notification.target_status.id}")
              when 'Follow' then web_url("accounts/#{notification.follow.id}")
              when 'FollowRequest' then web_url('follow_requests')
              when 'Favourite' then web_url("statuses/#{notification.target_status.id}")
              when 'Status' then web_url("statuses/#{notification.target_status.id}")
            end

      Webpush.payload_send(
        message: JSON.generate(
          title: title,
          options: {
            body: notification.status.text,
            tag: notification.id,
            timestamp: notification.created_at,
            icon: notification.from_account.avatar_static_url,
            data: {
              url: url,
            }
          }
        ),
        endpoint: endpoint,
        p256dh: key_p256dh,
        auth: key_auth,
        vapid: {
          private_key: Redis.current.get('vapid_private_key'),
          public_key: Redis.current.get('vapid_public_key')
        }
      )
    rescue Webpush::InvalidSubscription
      destroy!
    rescue Webpush::ResponseError
      destroy!
    end
  end
end
