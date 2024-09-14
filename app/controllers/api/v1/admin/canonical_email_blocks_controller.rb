# frozen_string_literal: true

class Api::V1::Admin::CanonicalEmailBlocksController < Api::BaseController
  include Authorization
  include AccountableConcern

  LIMIT = 100

  before_action -> { authorize_if_got_token! :'admin:read', :'admin:read:canonical_email_blocks' }, only: [:index, :show, :test]
  before_action -> { authorize_if_got_token! :'admin:write', :'admin:write:canonical_email_blocks' }, except: [:index, :show, :test]

  before_action :set_canonical_email_blocks, only: :index
  before_action :set_canonical_email_blocks_from_test, only: [:test]
  before_action :set_canonical_email_block, only: [:show, :destroy]

  after_action :verify_authorized
  after_action :insert_pagination_headers, only: :index

  def index
    authorize :canonical_email_block, :index?
    render json: @canonical_email_blocks, each_serializer: REST::Admin::CanonicalEmailBlockSerializer
  end

  def show
    authorize @canonical_email_block, :show?
    render json: @canonical_email_block, serializer: REST::Admin::CanonicalEmailBlockSerializer
  end

  def test
    authorize :canonical_email_block, :test?
    render json: @canonical_email_blocks, each_serializer: REST::Admin::CanonicalEmailBlockSerializer
  end

  def create
    authorize :canonical_email_block, :create?
    @canonical_email_block = CanonicalEmailBlock.create!(resource_params)
    log_action :create, @canonical_email_block
    render json: @canonical_email_block, serializer: REST::Admin::CanonicalEmailBlockSerializer
  end

  def destroy
    authorize @canonical_email_block, :destroy?
    @canonical_email_block.destroy!
    log_action :destroy, @canonical_email_block
    render_empty
  end

  private

  def resource_params
    params.permit(:canonical_email_hash, :email)
  end

  def set_canonical_email_blocks
    @canonical_email_blocks = CanonicalEmailBlock.order(id: :desc).to_a_paginated_by_id(limit_param(LIMIT), params_slice(:max_id, :since_id, :min_id))
  end

  def set_canonical_email_blocks_from_test
    @canonical_email_blocks = CanonicalEmailBlock.matching_email(params.require(:email))
  end

  def set_canonical_email_block
    @canonical_email_block = CanonicalEmailBlock.find(params[:id])
  end

  def next_path
    api_v1_admin_canonical_email_blocks_url(pagination_params(max_id: pagination_max_id)) if records_continue?
  end

  def prev_path
    api_v1_admin_canonical_email_blocks_url(pagination_params(min_id: pagination_since_id)) unless @canonical_email_blocks.empty?
  end

  def pagination_collection
    @canonical_email_blocks
  end

  def records_continue?
    @canonical_email_blocks.size == limit_param(LIMIT)
  end
end
