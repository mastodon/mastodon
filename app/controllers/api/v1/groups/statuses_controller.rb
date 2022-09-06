# frozen_string_literal: true

class Api::V1::Groups::StatusesController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :write, :'write:groups' }
  before_action :set_status

  def destroy
    authorize @status.group, :delete_posts?
    #TODO: refactor
    #TODO: logging
    #TODO: notifying user
    if @status.local?
      RejectGroupStatusService.new.call(@status)
    else
      RemoveStatusService.new.call(@status) #TODO: federation
    end
    render json: @status, serializer: REST::StatusSerializer
  end

  private

  def set_status
    @status = Status.includes(:group).where(group_id: params[:group_id]).find(params[:id])
    not_found if @status.group.nil?
  end
end
