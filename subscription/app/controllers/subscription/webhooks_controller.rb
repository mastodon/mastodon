module Subscription
  class WebhooksController < Subscription::ApplicationController
    protect_from_forgery with: :null_session

    def receive
      WebhookWorker.perform_async(params[:id])

      render body: nil, layout: false, status: 201
    end
  end
end