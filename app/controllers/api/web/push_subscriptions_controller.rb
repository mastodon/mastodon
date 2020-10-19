# frozen_string_literal: true

class Api::Web::PushSubscriptionsController < Api::Web::BaseController
  before_action :require_user!

  def create
    active_session = current_session

    unless active_session.web_push_subscription.nil?
      active_session.web_push_subscription.destroy!
      active_session.update!(web_push_subscription: nil)
    end

    # Mobile devices do not support regular notifications, so we enable push notifications by default
    alerts_enabled = active_session.detection.device.mobile? || active_session.detection.device.tablet?

    data = {
      alerts: {
        follow: alerts_enabled,
        follow_request: false,
        favourite: alerts_enabled,
        reblog: alerts_enabled,
        mention: alerts_enabled,
        poll: alerts_enabled,
        status: alerts_enabled,
      },
    }

    data.deep_merge!(data_params) if params[:data]

    web_subscription = ::Web::PushSubscription.create!(
      endpoint: subscription_params[:endpoint],
      key_p256dh: subscription_params[:keys][:p256dh],
      key_auth: subscription_params[:keys][:auth],
      data: data,
      user_id: active_session.user_id,
      access_token_id: active_session.access_token_id
    )

    active_session.update!(web_push_subscription: web_subscription)

    render json: web_subscription, serializer: REST::WebPushSubscriptionSerializer
  end

  def update
    params.require([:id])

    web_subscription = ::Web::PushSubscription.find(params[:id])
    web_subscription.update!(data: data_params)

    render json: web_subscription, serializer: REST::WebPushSubscriptionSerializer
  end

  private

  def subscription_params
    @subscription_params ||= params.require(:subscription).permit(:endpoint, keys: [:auth, :p256dh])
  end

  def data_params
    @data_params ||= params.require(:data).permit(alerts: [:follow, :follow_request, :favourite, :reblog, :mention, :poll, :status])
  end
end
