# frozen_string_literal: true

class Api::V1::Crypto::Keys::CountsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :crypto }
  before_action :require_user!
  before_action :set_current_device

  def show
    render json: { one_time_keys: @current_device.one_time_keys.count }
  end

  private

  def set_current_device
    @current_device = Device.find_by!(access_token: doorkeeper_token)
  end
end
