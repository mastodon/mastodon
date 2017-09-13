# frozen_string_literal: true

class Api::Web::PushSubscriptionsController < Api::BaseController
  respond_to :json

  before_action :require_user!

  def create
    params.require(:subscription).require(:endpoint)
    params.require(:subscription).require(:keys).require([:auth, :p256dh])

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
        favourite: alerts_enabled,
        reblog: alerts_enabled,
        mention: alerts_enabled,
      },
    }

    web_subscription = ::Web::PushSubscription.create!(
      endpoint: params[:subscription][:endpoint],
      key_p256dh: params[:subscription][:keys][:p256dh],
      key_auth: params[:subscription][:keys][:auth],
      data: data
    )

    active_session.update!(web_push_subscription: web_subscription)

    render json: web_subscription.as_payload
  end

  def update
    params.require([:id, :data])

    web_subscription = ::Web::PushSubscription.find(params[:id])

    web_subscription.update!(data: params[:data])

    render json: web_subscription.as_payload
  end
end
