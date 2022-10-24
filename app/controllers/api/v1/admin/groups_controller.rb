# frozen_string_literal: true

class Api::V1::Admin::GroupsController < Api::BaseController
  include Authorization
  include AccountableConcern

  LIMIT = 100

  before_action -> { authorize_if_got_token! :'admin:read', :'admin:read:groups' }, only: [:index, :show]
  before_action -> { authorize_if_got_token! :'admin:write', :'admin:write:groups' }, except: [:index, :show]
  before_action :set_groups, only: :index
  before_action :set_group, except: :index

  after_action :verify_authorized
  after_action :insert_pagination_headers, only: :index

  FILTER_PARAMS = %i(
    origin
    status
    by_domain
    display_name
    order
    by_member
  ).freeze

  PAGINATION_PARAMS = (%i(limit) + FILTER_PARAMS).freeze

  def index
    authorize :group, :index?
    render json: @groups, each_serializer: REST::GroupSerializer
  end

  def show
    authorize @group, :show?
    render json: @group, serializer: REST::GroupSerializer
  end

  def suspend
    authorize @group, :suspend?
    @group.suspend!
    Admin::GroupSuspensionWorker.perform_async(@group.id)
    log_action :suspend, @group
    render json: @group, serializer: REST::GroupSerializer
  end

  def unsuspend
    authorize @group, :unsuspend?
    @group.unsuspend!
    Admin::GroupUnsuspensionWorker.perform_async(@group.id)
    log_action :unsuspend, @group
    render json: @group, serializer: REST::GroupSerializer
  end

  def destroy
    authorize @group, :destroy?
    json = render_to_body json: @group, serializer: REST::GroupSerializer
    Admin::GroupDeletionWorker.perform_async(@group.id)
    render json: json
  end

  private

  def set_groups
    @groups = filtered_groups.order(id: :desc).to_a_paginated_by_id(limit_param(LIMIT), params_slice(:max_id, :since_id, :min_id))
  end

  def set_group
    @group = Group.find(params[:id])
  end

  def filtered_groups
    GroupFilter.new(filter_params.with_defaults(order: 'recent')).results
  end

  def filter_params
    params.permit(*FILTER_PARAMS)
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    api_v1_admin_groups_url(pagination_params(max_id: pagination_max_id)) if records_continue?
  end

  def prev_path
    api_v1_admin_groups_url(pagination_params(min_id: pagination_since_id)) unless @groups.empty?
  end

  def pagination_max_id
    @groups.last.id
  end

  def pagination_since_id
    @groups.first.id
  end

  def records_continue?
    @groups.size == limit_param(LIMIT)
  end

  def pagination_params(core_params)
    params.slice(*PAGINATION_PARAMS).permit(*PAGINATION_PARAMS).merge(core_params)
  end
end
