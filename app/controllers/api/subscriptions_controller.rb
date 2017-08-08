# frozen_string_literal: true

class Api::SubscriptionsController < Api::BaseController
  before_action :set_account
  respond_to :txt

  def show
    if subscription.valid?(params['hub.topic'])
      @account.update(subscription_expires_at: future_expires)
      render plain: encoded_challenge, status: 200
    else
      head 404
    end
  end

  def update
    if subscription.verify(body, request.headers['HTTP_X_HUB_SIGNATURE'])
      ProcessingWorker.perform_async(@account.id, body.force_encoding('UTF-8'))
    end

    head 200
  end

  private

  def subscription
    @_subscription ||= @account.subscription(
      api_subscription_url(@account.id)
    )
  end

  def body
    @_body ||= request.body.read
  end

  def encoded_challenge
    HTMLEntities.new.encode(params['hub.challenge'])
  end

  def future_expires
    Time.now.utc + lease_seconds_or_default
  end

  def lease_seconds_or_default
    (params['hub.lease_seconds'] || 1.day).to_i.seconds
  end

  def set_account
    @account = Account.find(params[:id])
  end
end
