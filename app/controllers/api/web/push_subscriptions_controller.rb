# frozen_string_literal: true

class Api::Web::PushSubscriptionsController < ApiController
  respond_to :json

  before_action :require_user!

  def create
    return update if params[:data].key?('alerts')

    web_subscription = WebPushSubscription.new(
      endpoint: params[:data][:endpoint],
      key_p256dh: params[:data][:keys][:p256dh],
      key_auth: params[:data][:keys][:auth]
    )

    current_account.web_push_subscriptions << web_subscription
    current_account.save!

    render json: web_subscription.as_payload
  end

  def update
    # TODO: Call from /api/web/push_subscriptions/:id
    web_subscription = WebPushSubscription.find(params[:data][:id])

    web_subscription.data = params[:data]
    web_subscription.save!

    render json: web_subscription.as_payload
  end
end
