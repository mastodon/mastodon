# frozen_string_literal: true

class Api::V1::Crypto::DeliveriesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :crypto }
  before_action :require_user!
  before_action :set_current_device

  def create
    devices.each do |device_params|
      DeliverToDeviceService.new.call(current_account, @current_device, device_params)
    end

    render_empty
  end

  private

  def set_current_device
    @current_device = Device.find_by!(access_token: doorkeeper_token)
  end

  def resource_params
    params.require(:device)
    params.permit(device: [:account_id, :device_id, :type, :body, :hmac])
  end

  def devices
    Array(resource_params[:device])
  end
end
