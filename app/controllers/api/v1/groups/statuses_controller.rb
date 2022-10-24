# frozen_string_literal: true

class Api::V1::Groups::StatusesController < Api::BaseController
  include Authorization
  include Payloadable

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
      RemoveStatusService.new.call(@status)
    end

    distribute_remove_to_remote_members!

    render json: @status, serializer: REST::StatusSerializer
  end

  private

  def set_status
    @status = Status.includes(:group).where(group_id: params[:group_id]).find(params[:id])
    not_found if @status.group.nil?
  end

  def distribute_remove_to_remote_members!
    json = Oj.dump(serialize_payload(@status, ActivityPub::RemoveSerializer, target: ActivityPub::TagManager.instance.wall_uri_for(@status.group), actor: ActivityPub::TagManager.instance.uri_for(@status.group)))
    ActivityPub::GroupRawDistributionWorker.perform_async(json, @status.group.id)
  end
end
