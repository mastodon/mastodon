# frozen_string_literal: true

# == Schema Information
#
# Table name: web_push_subscriptions
#
#  id              :bigint(8)        not null, primary key
#  data            :json
#  endpoint        :string           not null
#  key_auth        :string           not null
#  key_p256dh      :string           not null
#  standard        :boolean          default(FALSE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  access_token_id :bigint(8)        not null
#  user_id         :bigint(8)        not null
#

class Web::PushSubscription < ApplicationRecord
  belongs_to :user
  belongs_to :access_token, class_name: 'Doorkeeper::AccessToken'

  has_one :session_activation, foreign_key: 'web_push_subscription_id', inverse_of: :web_push_subscription, dependent: nil

  validates :endpoint, presence: true, url: true
  validates :key_p256dh, presence: true
  validates :key_auth, presence: true

  validates_with WebPushKeyValidator

  delegate :locale, to: :user

  generates_token_for :unsubscribe, expires_in: Web::PushNotificationWorker::TTL

  def pushable?(notification)
    policy_allows_notification?(notification) && alert_enabled_for_notification_type?(notification)
  end

  def associated_access_token
    access_token.token
  end

  class << self
    def unsubscribe_for(application_id, resource_owner)
      access_token_ids = Doorkeeper::AccessToken.where(application_id: application_id, resource_owner_id: resource_owner.id).not_revoked.pluck(:id)
      where(access_token_id: access_token_ids).delete_all
    end
  end

  private

  def alert_enabled_for_notification_type?(notification)
    truthy?(data&.dig('alerts', notification.type.to_s))
  end

  def policy_allows_notification?(notification)
    case data&.dig('policy')
    when nil, 'all'
      true
    when 'none'
      false
    when 'followed'
      notification.account.following?(notification.from_account)
    when 'follower'
      notification.from_account.following?(notification.account)
    end
  end

  def truthy?(val)
    ActiveModel::Type::Boolean.new.cast(val)
  end
end
