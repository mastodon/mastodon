# frozen_string_literal: true

module Admin
  class PubsubhubbubController < BaseController
    def index
      @subscriptions = Subscription.order('id desc').includes(:account).paginate(page: params[:page], per_page: 40)
    end
  end
end
