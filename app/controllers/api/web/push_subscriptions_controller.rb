# frozen_string_literal: true

class Api::Web::PushSubscriptionsController < Api::Web::BaseController
  before_action :require_user!, except: :destroy
  before_action :set_push_subscription, only: :update
  before_action :destroy_previous_subscriptions, only: :create, if: :prior_subscriptions?
  after_action :update_session_with_subscription, only: :create

  def create
    @push_subscription = ::Web::PushSubscription.create!(web_push_subscription_params)

    render json: @push_subscription, serializer: REST::WebPushSubscriptionSerializer
  end

  def update
    @push_subscription.update!(data: data_params)
    render json: @push_subscription, serializer: REST::WebPushSubscriptionSerializer
  end

  def destroy
    push_subscription = ::Web::PushSubscription.find_by_token_for(:unsubscribe, params[:id])
    push_subscription&.destroy

    head 200
  end

  private

  def active_session
    @active_session ||= current_session
  end

  def destroy_previous_subscriptions
    active_session.web_push_subscription.destroy!
    active_session.update!(web_push_subscription: nil)
  end

  def prior_subscriptions?
    active_session.web_push_subscription.present?
  end

  def subscription_data
    default_subscription_data.tap do |data|
      data.deep_merge!(data_params) if params[:data]
    end
  end

  def default_subscription_data
    {
      policy: 'all',
      alerts: Notification::TYPES.index_with { alerts_enabled },
    }
  end

  def alerts_enabled
    # Mobile devices do not support regular notifications, so we enable push notifications by default
    active_session.detection.device.mobile? || active_session.detection.device.tablet?
  end

  def update_session_with_subscription
    active_session.update!(web_push_subscription: @push_subscription)
  end

  def set_push_subscription
    @push_subscription = ::Web::PushSubscription.find(params[:id])
  end

  def subscription_params
    @subscription_params ||= params.require(:subscription).permit(:endpoint, keys: [:auth, :p256dh])
  end

  def web_push_subscription_params
    {
      access_token_id: active_session.access_token_id,
      data: subscription_data,
      endpoint: subscription_params[:endpoint],
      key_auth: subscription_params[:keys][:auth],
      key_p256dh: subscription_params[:keys][:p256dh],
      user_id: active_session.user_id,
    }
  end

  def data_params
    @data_params ||= params.require(:data).permit(:policy, alerts: Notification::TYPES)
  end
end
