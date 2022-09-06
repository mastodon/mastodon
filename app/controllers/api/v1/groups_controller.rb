# frozen_string_literal: true

class Api::V1::GroupsController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :read, :'read:groups' }, only: [:index, :show]
  before_action -> { doorkeeper_authorize! :write, :'write:groups' }, except: [:index, :show]

  before_action :require_user!, except: [:show]
  before_action :set_group, except: [:index, :create]

  def index
    @groups = Group.joins(:members).where(members: { id: current_account.id })
    render json: @groups, each_serializer: REST::GroupSerializer
  end

  def show
    render json: @group, serializer: REST::GroupSerializer
  end

  def join
    JoinGroupService.new.call(current_user.account, @group)
    options = @group.locked? || current_user.account.silenced? ? {} : { member_map: { @group.id => { role: :user } }, requested_map: { @group.id => false } }

    render json: @group, serializer: REST::GroupRelationshipSerializer, relationships: relationships(**options)
  end

  def leave
    LeaveGroupService.new.call(current_user.account, @group)
    render json: @group, serializer: REST::GroupRelationshipSerializer, relationships: relationships
  end

  def kick
    memberships = @group.memberships.where(account_id: account_ids).to_a
    memberships.each { |membership| authorize membership, :revoke? }

    #TODO: refactor
    #TODO: logging

    memberships.each(&:destroy) #TODO: federate

    render_empty
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def relationships(**options)
    GroupRelationshipsPresenter.new([@group.id], current_user.account_id, **options)
  end

  def resource_params
    params.permit(account_ids: [])
  end

  def account_ids
    Array(resource_params[:account_ids])
  end
end
