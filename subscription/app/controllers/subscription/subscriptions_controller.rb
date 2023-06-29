module Subscription
  class SubscriptionsController < ::Settings::BaseController
    before_action :set_user

    def index
      @subscriptions = StripeSubscription.all.where(user_id: current_account.user.id)
    end

    def show
      @subscription = StripeSubscription.find(params[:id])
      @url = ::Stripe::BillingPortal::Session.create({
        customer: @subscription.customer_id,
    }).url
    end

    private
    def set_user
      @user = current_account.user
    end
  end
end