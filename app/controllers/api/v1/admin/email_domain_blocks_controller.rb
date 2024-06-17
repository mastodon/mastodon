# frozen_string_literal: true

class Api::V1::Admin::EmailDomainBlocksController < Api::BaseController
  include Authorization
  include AccountableConcern

  LIMIT = 100

  before_action -> { authorize_if_got_token! :'admin:read', :'admin:read:email_domain_blocks' }, only: [:index, :show]
  before_action -> { authorize_if_got_token! :'admin:write', :'admin:write:email_domain_blocks' }, except: [:index, :show]
  before_action :set_email_domain_blocks, only: :index
  before_action :set_email_domain_block, only: [:show, :destroy]

  after_action :verify_authorized
  after_action :insert_pagination_headers, only: :index

  def index
    authorize :email_domain_block, :index?
    render json: @email_domain_blocks, each_serializer: REST::Admin::EmailDomainBlockSerializer
  end

  def show
    authorize @email_domain_block, :show?
    render json: @email_domain_block, serializer: REST::Admin::EmailDomainBlockSerializer
  end

  def create
    authorize :email_domain_block, :create?

    @email_domain_block = EmailDomainBlock.create!(resource_params)
    log_action :create, @email_domain_block

    render json: @email_domain_block, serializer: REST::Admin::EmailDomainBlockSerializer
  end

  def destroy
    authorize @email_domain_block, :destroy?
    @email_domain_block.destroy!
    log_action :destroy, @email_domain_block
    render_empty
  end

  private

  def set_email_domain_blocks
    @email_domain_blocks = EmailDomainBlock.order(id: :desc).to_a_paginated_by_id(limit_param(LIMIT), params_slice(:max_id, :since_id, :min_id))
  end

  def set_email_domain_block
    @email_domain_block = EmailDomainBlock.find(params[:id])
  end

  def resource_params
    params.permit(:domain, :allow_with_approval)
  end

  def next_path
    api_v1_admin_email_domain_blocks_url(pagination_params(max_id: pagination_max_id)) if records_continue?
  end

  def prev_path
    api_v1_admin_email_domain_blocks_url(pagination_params(min_id: pagination_since_id)) unless @email_domain_blocks.empty?
  end

  def pagination_collection
    @email_domain_blocks
  end

  def records_continue?
    @email_domain_blocks.size == limit_param(LIMIT)
  end
end
