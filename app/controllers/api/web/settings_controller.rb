# frozen_string_literal: true

class Api::Web::SettingsController < Api::BaseController
  include ActionView::Helpers::TranslationHelper

  respond_to :json

  before_action :require_user!

  def update
    # TODO: Move someplace else, something like web/push_subscriptions
    if params[:data].key?(:web_push_subscription)
      save_subscription
    elsif params[:data].key?(:web_push_subscription_id)
      update_subscription
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

    render json: web_subscription.as_payload
  end

  def update_subscription
    web_subscription = WebPushSubscription.find(params[:data][:web_push_subscription_id])

    web_subscription.data = params[:data]
    web_subscription.save!
  end
end
