# frozen_string_literal: true

module Admin
  class Webhooks::SecretsController < BaseController
    before_action :set_webhook

    def rotate
      authorize @webhook, :rotate_secret?
      @webhook.rotate_secret!
      redirect_to admin_webhook_path(@webhook)
    end

    private

    def set_webhook
      @webhook = Webhook.find(params[:webhook_id])
    end
  end
end
