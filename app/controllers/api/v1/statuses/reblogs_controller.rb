# frozen_string_literal: true

class Api::V1::Statuses::ReblogsController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }
  before_action :require_user!

  respond_to :json

  def create
    @status = ReblogService.new.call(current_user.account, status_for_reblog, reblog_params)
    render json: @status, serializer: REST::StatusSerializer
  end

  def destroy
    status_for_destroy = current_user.account.statuses.find_by(reblog_of_id: params[:status_id])
    if status_for_destroy.nil?
      @status = Status.find(params[:status_id])
    else
      @status = status_for_destroy.reblog
      authorize status_for_destroy, :unreblog?
      status_for_destroy.discard
      RemovalWorker.perform_async(status_for_destroy.id)
    end

    @reblogs_map = { @status.id => false }

    render json: @status, serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new([@status], current_user&.account_id, reblogs_map: @reblogs_map)
  end

  private

  def status_for_reblog
    Status.find params[:status_id]
  end

  def reblog_params
    params.permit(:visibility)
  end
end
