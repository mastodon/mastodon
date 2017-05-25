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
  include StreamEntriesHelper

  def push(notification)
    begin
      name = display_name(notification.from_account)

      title = case notification.activity_type
        when 'Mention' then "#{name} mentioned you"
        when 'Follow' then "#{name} followed you"
        when 'FollowRequest' then "#{name} requested to follow you"
        when 'Favourite' then "#{name} favourited your status"
        when 'Status' then "#{name} boosted your status"
      end

      body = case notification.activity_type
         when 'Mention' then notification.target_status.text
         when 'Follow' then notification.from_account.note
         when 'FollowRequest' then notification.from_account.note
         when 'Favourite' then notification.target_status.text
         when 'Status' then notification.target_status.text
      end

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
            body: body,
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
