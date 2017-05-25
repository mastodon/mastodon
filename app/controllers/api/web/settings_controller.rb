# frozen_string_literal: true

class Api::Web::SettingsController < Api::BaseController
  include ActionView::Helpers::TranslationHelper

  respond_to :json

  before_action :require_user!

  def update
    if params[:data].key?(:web_push_subscription)
      save_subscription
    else
      setting.data = params[:data]
      setting.save!

      render_empty
    end
  end

  private

  def setting
    @_setting ||= ::Web::Setting.where(user: current_user).first_or_initialize(user: current_user)
  end

  def save_subscription
    web_subscription = WebPushSubscription.new(
      endpoint: params[:data][:web_push_subscription][:endpoint],
      key_p256dh: params[:data][:web_push_subscription][:keys][:p256dh],
      key_auth: params[:data][:web_push_subscription][:keys][:auth]
    )

    current_account.web_push_subscriptions << web_subscription
    current_account.save!

    Webpush.payload_send(
      message: JSON.generate(
        title: translate('push_notifications.subscribed.title'),
        options: {
          body: translate('push_notifications.subscribed.body'),
        }
      ),
      endpoint: web_subscription.endpoint,
      p256dh: web_subscription.key_p256dh,
      auth: web_subscription.key_auth,
      vapid: {
        private_key: Redis.current.get('vapid_private_key'),
        public_key: Redis.current.get('vapid_public_key'),
      }
    )
  end
end
