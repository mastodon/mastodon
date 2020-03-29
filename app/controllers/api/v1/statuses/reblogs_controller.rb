# frozen_string_literal: true

class Api::V1::Statuses::ReblogsController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }
  before_action :require_user!
  before_action :set_reblog

  respond_to :json

  def create
    @status = ReblogService.new.call(current_account, @reblog, reblog_params)
    render json: @status, serializer: REST::StatusSerializer
  end

  def destroy
    @status = current_account.statuses.find_by(reblog_of_id: @reblog.id)

    authorize status_for_destroy, :unreblog?
    status_for_destroy.discard
    RemovalWorker.perform_async(status_for_destroy.id)

    render json: @reblog, serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new([@status], current_account.id, reblogs_map: { @reblog.id => false })
  end

  private

  def status_for_reblog
    Status.find params[:status_id]
  end

  def status_for_destroy
    @status_for_destroy ||= current_user.account.statuses.where(reblog_of_id: params[:status_id]).first!
  end

  def reblog_params
    params.permit(:visibility)
  end
end
