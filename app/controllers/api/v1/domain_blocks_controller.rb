# frozen_string_literal: true

class Api::V1::DomainBlocksController < ApiController
  before_action -> { doorkeeper_authorize! :follow }
  before_action :require_user!

  respond_to :json

  def show
    @blocks = AccountDomainBlock.where(account: current_account).paginate_by_max_id(limit_param(100), params[:max_id], params[:since_id])

    next_path = api_v1_domain_blocks_url(pagination_params(max_id: @blocks.last.id))    if @blocks.size == limit_param(100)
    prev_path = api_v1_domain_blocks_url(pagination_params(since_id: @blocks.first.id)) unless @blocks.empty?

    set_pagination_headers(next_path, prev_path)
    render json: @blocks.map(&:domain)
  end

  def create
    current_account.block_domain!(domain_block_params[:domain])
    render_empty
  end

  def destroy
    current_account.unblock_domain!(domain_block_params[:domain])
    render_empty
  end

  private

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end

  def domain_block_params
    params.permit(:domain)
  end
end
