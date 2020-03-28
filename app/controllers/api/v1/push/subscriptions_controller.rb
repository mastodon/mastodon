# frozen_string_literal: true

class Api::V1::Push::SubscriptionsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :push }
  before_action :require_user!
  before_action :set_web_push_subscription

  def create
    @web_subscription&.destroy!

    @web_subscription = ::Web::PushSubscription.create!(
      endpoint: subscription_params[:endpoint],
      key_p256dh: subscription_params[:keys][:p256dh],
      key_auth: subscription_params[:keys][:auth],
      data: data_params,
      user_id: current_user.id,
      access_token_id: doorkeeper_token.id
    )

    render json: @web_subscription, serializer: REST::WebPushSubscriptionSerializer
  end

  def show
    raise ActiveRecord::RecordNotFound if @web_subscription.nil?

    render json: @web_subscription, serializer: REST::WebPushSubscriptionSerializer
  end

  def update
    raise ActiveRecord::RecordNotFound if @web_subscription.nil?

    @web_subscription.update!(data: data_params)

    render json: @web_subscription, serializer: REST::WebPushSubscriptionSerializer
  end

  def destroy
    @web_subscription&.destroy!
    render_empty
  end

  private

  def set_web_push_subscription
    @web_subscription = ::Web::PushSubscription.find_by(access_token_id: doorkeeper_token.id)
  end

  def subscription_params
    params.require(:subscription).permit(:endpoint, keys: [:auth, :p256dh])
  end

  def data_params
    return {} if params[:data].blank?
    params.require(:data).permit(alerts: [:follow, :favourite, :reblog, :mention, :poll])
  end
end
