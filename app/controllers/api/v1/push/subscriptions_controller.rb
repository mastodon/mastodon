# frozen_string_literal: true

class Api::V1::Push::SubscriptionsController < Api::BaseController
  include Redisable
  include Lockable

  before_action -> { doorkeeper_authorize! :push }
  before_action :require_user!
  before_action :set_push_subscription, only: [:show, :update]
  before_action :check_push_subscription, only: [:show, :update]

  def show
    render json: @push_subscription, serializer: REST::WebPushSubscriptionSerializer
  end

  def create
    with_redis_lock("push_subscription:#{current_user.id}") do
      destroy_web_push_subscriptions!

      @push_subscription = Web::PushSubscription.create!(
        endpoint: subscription_params[:endpoint],
        key_p256dh: subscription_params[:keys][:p256dh],
        key_auth: subscription_params[:keys][:auth],
        data: data_params,
        user_id: current_user.id,
        access_token_id: doorkeeper_token.id
      )
    end

    render json: @push_subscription, serializer: REST::WebPushSubscriptionSerializer
  end

  def update
    @push_subscription.update!(data: data_params)
    render json: @push_subscription, serializer: REST::WebPushSubscriptionSerializer
  end

  def destroy
    destroy_web_push_subscriptions!
    render_empty
  end

  private

  def destroy_web_push_subscriptions!
    doorkeeper_token.web_push_subscriptions.destroy_all
  end

  def set_push_subscription
    @push_subscription = doorkeeper_token.web_push_subscriptions.first
  end

  def check_push_subscription
    not_found if @push_subscription.nil?
  end

  def subscription_params
    params.require(:subscription).permit(:endpoint, keys: [:auth, :p256dh])
  end

  def data_params
    return {} if params[:data].blank?

    params.require(:data).permit(:policy, alerts: Notification::TYPES)
  end
end
