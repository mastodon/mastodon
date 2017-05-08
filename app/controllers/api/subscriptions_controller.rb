# frozen_string_literal: true

class Api::SubscriptionsController < ApiController
  before_action :set_account
  respond_to :txt

  def show
    if @account.subscription(api_subscription_url(@account.id)).valid?(params['hub.topic'])
      @account.update(subscription_expires_at: Time.now.utc + (params['hub.lease_seconds'] || 86_400).to_i.seconds)
      render plain: HTMLEntities.new.encode(params['hub.challenge']), status: 200
    else
      head 404
    end
  end

  def update
    body = request.body.read
    subscription = @account.subscription(api_subscription_url(@account.id))

    if subscription.verify(body, request.headers['HTTP_X_HUB_SIGNATURE'])
      ProcessingWorker.perform_async(@account.id, body.force_encoding('UTF-8'))
    end

    head 200
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end
end
