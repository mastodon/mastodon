module Subscription
  class SubscriptionsController < ::Settings::BaseController
    before_action :set_user
    skip_before_action :require_functional!

    def index
      @subscriptions = StripeSubscription.all.where(user_id: current_account.user.id)
      @urls = @subscriptions.each_with_object({}) do |sub, hash|
        hash[sub.id] = ::Stripe::BillingPortal::Session.create({
          customer: sub.customer_id,
        }).url
      end
    end

    def create
      single = [{
        price: ENV['STRIPE_PRICE_1'],
        quantity: 1,
      }]
      group = [{
        price: ENV['STRIPE_PRICE_2'],
        quantity: params[:quantity].to_i || 1,
        adjustable_quantity: {
          enabled: true,
          minimum: 1,
        },
      }]
      items = params[:quantity] ? group : single
      session = ::Stripe::Checkout::Session.create({
        line_items: items,
        mode: 'subscription',
        client_reference_id: @user.id,
        allow_promotion_codes: true,
        success_url: settings_subscription.subscriptions_url,
      })
      Subscription::CheckoutSession.create(session_id: session.id, user_id: @user.id)

      redirect_to session.url, status: 303
    end

    private
    def set_user
      @user = current_account.user
    end
  end
end