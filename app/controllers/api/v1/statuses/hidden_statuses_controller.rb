# frozen_string_literal: true

class Api::V1::Statuses::HiddenStatusesController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:hidden' }
  before_action :require_user!

  respond_to :json

  def create
    @status = hidden_status
    render json: @status, serializer: REST::StatusSerializer
  end

  private

  def hidden_status
    authorize_with current_user.account, requested_status, :show?

    hide = HiddenStatus.find_or_create_by!(account: current_user.account, status: requested_status)

    hide.status.reload
  end

  def requested_status
    Status.find(params[:status_id])
  end
end
