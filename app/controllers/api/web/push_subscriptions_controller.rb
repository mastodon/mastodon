# frozen_string_literal: true

class Api::Web::PushSubscriptionsController < Api::BaseController
  respond_to :json

  before_action :require_user!

  def create
    web_subscription = ::Web::PushSubscription.new(
      endpoint: params[:data][:endpoint],
      key_p256dh: params[:data][:keys][:p256dh],
      key_auth: params[:data][:keys][:auth]
    )

    web_subscription.save!

    current_account.user.active_session.web_push_subscription = web_subscription
    current_account.user.active_session.save!

    render json: web_subscription.as_payload
  end

  def update
    web_subscription = ::Web::PushSubscription.find(params[:id])

    web_subscription.data = params[:data]
    web_subscription.save!

    render json: web_subscription.as_payload
  end
end
