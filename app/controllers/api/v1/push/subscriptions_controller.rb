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
      @push_subscription = Web::PushSubscription.create!(web_push_subscription_params)
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

  def web_push_subscription_params
    {
      access_token_id: doorkeeper_token.id,
      data: data_params,
      endpoint: subscription_params[:endpoint],
      key_auth: subscription_params[:keys][:auth],
      key_p256dh: subscription_params[:keys][:p256dh],
      standard: subscription_params[:standard] || false,
      user_id: current_user.id,
    }
  end

  def subscription_params
    params.expect(subscription: [:endpoint, :standard, keys: [:auth, :p256dh]])
  end

  def data_params
    return {} if params[:data].blank?

    params.expect(data: [:policy, alerts: Notification::TYPES])
  end
end
