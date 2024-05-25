# frozen_string_literal: true

class Api::V1::Admin::IpBlocksController < Api::BaseController
  include Authorization
  include AccountableConcern

  LIMIT = 100

  before_action -> { authorize_if_got_token! :'admin:read', :'admin:read:ip_blocks' }, only: [:index, :show]
  before_action -> { authorize_if_got_token! :'admin:write', :'admin:write:ip_blocks' }, except: [:index, :show]
  before_action :set_ip_blocks, only: :index
  before_action :set_ip_block, only: [:show, :update, :destroy]

  after_action :verify_authorized
  after_action :insert_pagination_headers, only: :index

  PAGINATION_PARAMS = %i(
    limit
  ).freeze

  def index
    authorize :ip_block, :index?
    render json: @ip_blocks, each_serializer: REST::Admin::IpBlockSerializer
  end

  def show
    authorize @ip_block, :show?
    render json: @ip_block, serializer: REST::Admin::IpBlockSerializer
  end

  def create
    authorize :ip_block, :create?
    @ip_block = IpBlock.create!(resource_params)
    log_action :create, @ip_block
    render json: @ip_block, serializer: REST::Admin::IpBlockSerializer
  end

  def update
    authorize @ip_block, :update?
    @ip_block.update(resource_params)
    log_action :update, @ip_block
    render json: @ip_block, serializer: REST::Admin::IpBlockSerializer
  end

  def destroy
    authorize @ip_block, :destroy?
    @ip_block.destroy!
    log_action :destroy, @ip_block
    render_empty
  end

  private

  def set_ip_blocks
    @ip_blocks = IpBlock.order(id: :desc).to_a_paginated_by_id(limit_param(LIMIT), params_slice(:max_id, :since_id, :min_id))
  end

  def set_ip_block
    @ip_block = IpBlock.find(params[:id])
  end

  def resource_params
    params.permit(:ip, :severity, :comment, :expires_in)
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    api_v1_admin_ip_blocks_url(pagination_params(max_id: pagination_max_id)) if records_continue?
  end

  def prev_path
    api_v1_admin_ip_blocks_url(pagination_params(min_id: pagination_since_id)) unless @ip_blocks.empty?
  end

  def pagination_max_id
    @ip_blocks.last.id
  end

  def pagination_since_id
    @ip_blocks.first.id
  end

  def records_continue?
    @ip_blocks.size == limit_param(LIMIT)
  end

  def pagination_params(core_params)
    params.slice(*PAGINATION_PARAMS).permit(*PAGINATION_PARAMS).merge(core_params)
  end
end
