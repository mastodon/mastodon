# frozen_string_literal: true

class Api::V1::DomainBlocksController < Api::BaseController
  BLOCK_LIMIT = 100

  before_action -> { doorkeeper_authorize! :follow, :read, :'read:blocks' }, only: :show
  before_action -> { doorkeeper_authorize! :follow, :write, :'write:blocks' }, except: :show
  before_action :require_user!
  after_action :insert_pagination_headers, only: :show

  def show
    @blocks = load_domain_blocks
    render json: @blocks.map(&:domain)
  end

  def create
    current_account.block_domain!(domain_block_params[:domain])
    AfterAccountDomainBlockWorker.perform_async(current_account.id, domain_block_params[:domain])
    render_empty
  end

  def destroy
    current_account.unblock_domain!(domain_block_params[:domain])
    render_empty
  end

  private

  def load_domain_blocks
    account_domain_blocks.paginate_by_max_id(
      limit_param(BLOCK_LIMIT),
      params[:max_id],
      params[:since_id]
    )
  end

  def account_domain_blocks
    current_account.domain_blocks
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    api_v1_domain_blocks_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_domain_blocks_url pagination_params(since_id: pagination_since_id) unless @blocks.empty?
  end

  def pagination_max_id
    @blocks.last.id
  end

  def pagination_since_id
    @blocks.first.id
  end

  def records_continue?
    @blocks.size == limit_param(BLOCK_LIMIT)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end

  def domain_block_params
    params.permit(:domain)
  end
end
