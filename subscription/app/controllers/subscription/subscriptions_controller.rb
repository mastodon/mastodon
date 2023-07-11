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

    private
    def set_user
      @user = current_account.user
    end
  end
end