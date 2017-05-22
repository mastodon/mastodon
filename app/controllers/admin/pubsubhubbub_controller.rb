# frozen_string_literal: true

module Admin
  class PubsubhubbubController < BaseController
    def index
      @subscriptions = Subscription.order(id: :desc).includes(:account).page(params[:page])
    end
  end
end
