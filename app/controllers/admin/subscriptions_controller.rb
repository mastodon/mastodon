# frozen_string_literal: true

module Admin
  class SubscriptionsController < BaseController
    def index
      @subscriptions = ordered_subscriptions.page(requested_page)
    end

    private

    def ordered_subscriptions
      Subscription.order(id: :desc).includes(:account)
    end

    def requested_page
      params[:page].to_i
    end
  end
end
