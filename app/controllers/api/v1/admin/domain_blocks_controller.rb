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

  PAGINATION_PARAMS = %i(limit).freeze

  def create
    authorize :domain_block, :create?

    existing_domain_block = resource_params[:domain].present? ? DomainBlock.rule_for(resource_params[:domain]) : nil
    return render json: existing_domain_block, serializer: REST::Admin::ExistingDomainBlockErrorSerializer, status: 422 if existing_domain_block.present?

    @domain_block = DomainBlock.create!(resource_params)
    DomainBlockWorker.perform_async(@domain_block.id)
    log_action :create, @domain_block
    render json: @domain_block, serializer: REST::Admin::DomainBlockSerializer
  end

  def index
    authorize :domain_block, :index?
    render json: @domain_blocks, each_serializer: REST::Admin::DomainBlockSerializer
  end

  def show
    authorize @domain_block, :show?
    render json: @domain_block, serializer: REST::Admin::DomainBlockSerializer
  end

  def update
    authorize @domain_block, :update?
    @domain_block.update(domain_block_params)
    severity_changed = @domain_block.severity_changed?
    @domain_block.save!
    DomainBlockWorker.perform_async(@domain_block.id, severity_changed)
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

  def set_domain_blocks
    @domain_blocks = filtered_domain_blocks.order(id: :desc).to_a_paginated_by_id(limit_param(LIMIT), params_slice(:max_id, :since_id, :min_id))
  end

  def set_domain_block
    @domain_block = DomainBlock.find(params[:id])
  end

  def filtered_domain_blocks
    # TODO: no filtering yet
    DomainBlock.all
  end

  def domain_block_params
    params.permit(:severity, :reject_media, :reject_reports, :private_comment, :public_comment, :obfuscate)
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    api_v1_admin_domain_blocks_url(pagination_params(max_id: pagination_max_id)) if records_continue?
  end

  def prev_path
    api_v1_admin_domain_blocks_url(pagination_params(min_id: pagination_since_id)) unless @domain_blocks.empty?
  end

  def pagination_max_id
    @domain_blocks.last.id
  end

  def pagination_since_id
    @domain_blocks.first.id
  end

  def records_continue?
    @domain_blocks.size == limit_param(LIMIT)
  end

  def pagination_params(core_params)
    params.slice(*PAGINATION_PARAMS).permit(*PAGINATION_PARAMS).merge(core_params)
  end

  def resource_params
    params.permit(:domain, :severity, :reject_media, :reject_reports, :private_comment, :public_comment, :obfuscate)
  end
end
