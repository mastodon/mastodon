# frozen_string_literal: true

class Api::V1::Crypto::Keys::ClaimsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :crypto }
  before_action :require_user!
  before_action :set_claim_results

  def create
    render json: @claim_results, each_serializer: REST::Keys::ClaimResultSerializer
  end

  private

  def set_claim_results
    @claim_results = devices.map { |device_params| ::Keys::ClaimService.new.call(current_account, device_params[:account_id], device_params[:device_id]) }.compact
  end

  def resource_params
    params.permit(device: [:account_id, :device_id])
  end

  def devices
    Array(resource_params[:device])
  end
end
