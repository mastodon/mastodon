# frozen_string_literal: true

class Api::V1::DevicesController < ApiController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  respond_to :json

  def register
    Device.where(account: current_account, registration_id: params[:registration_id]).first_or_create!(account: current_account, registration_id: params[:registration_id])
    render_empty
  end

  def unregister
    Device.where(account: current_account, registration_id: params[:registration_id]).delete_all
    render_empty
  end
end
