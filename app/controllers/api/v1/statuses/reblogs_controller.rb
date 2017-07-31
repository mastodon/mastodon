# frozen_string_literal: true

class Api::V1::Statuses::ReblogsController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :write }
  before_action :require_user!

  respond_to :json

  def create
    @status = ReblogService.new.call(current_user.account, status_for_reblog)
    render json: @status, serializer: REST::StatusSerializer
  end

  def destroy
    @status = status_for_destroy.reblog
    @reblogs_map = { @status.id => false }

    authorize status_for_destroy, :unreblog?
    RemovalWorker.perform_async(status_for_destroy.id)

    render json: @status, serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new([@status], current_user&.account_id, reblogs_map: @reblogs_map)
  end

  private

  def status_for_reblog
    Status.find params[:status_id]
  end

  def status_for_destroy
    current_user.account.statuses.where(reblog_of_id: params[:status_id]).first!
  end
end
