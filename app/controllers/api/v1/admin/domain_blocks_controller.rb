# frozen_string_literal: true

class Api::V1::Admin::DomainBlocksController < Api::BaseController
  include Authorization
  include AccountableConcern

  LIMIT = 100

  before_action -> { authorize_if_got_token! :'admin:read', :'admin:read:domain_blocks' }, only: [:index, :show]
  before_action -> { authorize_if_got_token! :'admin:write', :'admin:write:domain_blocks' }, except: [:index, :show]
  before_action :set_domain_blocks, only: :index
  before_action :set_domain_block, only: [:show, :update, :destroy]

  after_action :verify_authorized
  after_action :insert_pagination_headers, only: :index

  def index
    authorize :domain_block, :index?
    render json: @domain_blocks, each_serializer: REST::Admin::DomainBlockSerializer
  end

  def show
    authorize @domain_block, :show?
    render json: @domain_block, serializer: REST::Admin::DomainBlockSerializer
  end

  def create
    authorize :domain_block, :create?

    @domain_block = DomainBlock.new(resource_params)
    existing_domain_block = resource_params[:domain].present? ? DomainBlock.rule_for(resource_params[:domain]) : nil
    return render json: existing_domain_block, serializer: REST::Admin::ExistingDomainBlockErrorSerializer, status: 422 if conflicts_with_existing_block?(@domain_block, existing_domain_block)

    @domain_block.save!
    DomainBlockWorker.perform_async(@domain_block.id)
    log_action :create, @domain_block
    render json: @domain_block, serializer: REST::Admin::DomainBlockSerializer
  end

  def update
    authorize @domain_block, :update?
    @domain_block.update!(domain_block_params)
    DomainBlockWorker.perform_async(@domain_block.id, @domain_block.severity_previously_changed?)
    log_action :update, @domain_block
    render json: @domain_block, serializer: REST::Admin::DomainBlockSerializer
  end

  def destroy
    authorize @domain_block, :destroy?
    UnblockDomainService.new.call(@domain_block)
    log_action :destroy, @domain_block
    render_empty
  end

  private

  def conflicts_with_existing_block?(domain_block, existing_domain_block)
    existing_domain_block.present? && (existing_domain_block.domain == TagManager.instance.normalize_domain(domain_block.domain) || !domain_block.stricter_than?(existing_domain_block))
  end

  def set_domain_blocks
    @domain_blocks = DomainBlock.order(id: :desc).to_a_paginated_by_id(limit_param(LIMIT), params_slice(:max_id, :since_id, :min_id))
  end

  def set_domain_block
    @domain_block = DomainBlock.find(params[:id])
  end

  def domain_block_params
    params.permit(:severity, :reject_media, :reject_reports, :private_comment, :public_comment, :obfuscate)
  end

  def next_path
    api_v1_admin_domain_blocks_url(pagination_params(max_id: pagination_max_id)) if records_continue?
  end

  def prev_path
    api_v1_admin_domain_blocks_url(pagination_params(min_id: pagination_since_id)) unless @domain_blocks.empty?
  end

  def pagination_collection
    @domain_blocks
  end

  def records_continue?
    @domain_blocks.size == limit_param(LIMIT)
  end

  def resource_params
    params.permit(:domain, :severity, :reject_media, :reject_reports, :private_comment, :public_comment, :obfuscate)
  end
end
