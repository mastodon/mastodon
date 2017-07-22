# frozen_string_literal: true

class Api::Web::PushSubscriptionsController < Api::BaseController
  respond_to :json

  before_action :require_user!

  def create
    params.require(:data).require(:endpoint)
    params.require(:data).require(:keys).require([:auth, :p256dh])

    active_session = current_session

    unless active_session.web_push_subscription.nil?
      active_session.web_push_subscription.destroy!
      active_session.update!(web_push_subscription: nil)
    end

    web_subscription = ::Web::PushSubscription.create!(
      endpoint: params[:data][:endpoint],
      key_p256dh: params[:data][:keys][:p256dh],
      key_auth: params[:data][:keys][:auth]
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
