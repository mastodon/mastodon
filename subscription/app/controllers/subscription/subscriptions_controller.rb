module Subscription
  class SubscriptionsController < ::Settings::BaseController
    before_action :set_user
    skip_before_action :require_functional!

    def index
      @subscriptions = StripeSubscription.all.where(user_id: current_account.user.id)
      if (@subscriptions.empty?)
        @subscriptions = SubscriptionMember.all.where(user_id: current_account.user.id).map(&:subscription)
      end
      @data = @subscriptions.each_with_object({}) do |sub, hash|
          url = ::Stripe::BillingPortal::Session.create({
            customer: sub.customer_id,
          }).url

          hash[sub.id] = {
            url: url,
            owner: sub.user_id == @user.id,
          }
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

      redirect_to session.url, status: 303
    end

    private
    def set_user
      @user = current_account.user
    end
  end
end