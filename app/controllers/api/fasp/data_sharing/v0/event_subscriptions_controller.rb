# frozen_string_literal: true

class Api::Fasp::DataSharing::V0::EventSubscriptionsController < Api::Fasp::BaseController
  def create
    subscription = current_provider.fasp_subscriptions.create!(subscription_params)

    render json: { subscription: { id: subscription.id } }, status: 201
  end

  def destroy
    subscription = current_provider.fasp_subscriptions.find(params[:id])
    subscription.destroy

    head 204
  end

  private

  def subscription_params
    params
      .permit(:category, :subscriptionType, :maxBatchSize, threshold: {})
      .to_unsafe_h
      .transform_keys { |k| k.to_s.underscore }
  end
end
