# frozen_string_literal: true

class Api::V1::Crypto::Keys::UploadsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :crypto }
  before_action :require_user!

  def create
    device = Device.find_or_initialize_by(access_token: doorkeeper_token)

    device.transaction do
      device.account = current_account
      device.update!(resource_params[:device])

      if resource_params[:one_time_keys].present? && resource_params[:one_time_keys].is_a?(Enumerable)
        resource_params[:one_time_keys].each do |one_time_key_params|
          device.one_time_keys.create!(one_time_key_params)
        end
      end
    end

    render json: device, serializer: REST::Keys::DeviceSerializer
  end

  private

  def resource_params
    params.permit(device: [:device_id, :name, :fingerprint_key, :identity_key], one_time_keys: [:key_id, :key, :signature])
  end
end
