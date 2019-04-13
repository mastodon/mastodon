# frozen_string_literal: true

class Api::V1::BlocksController < Api::BaseController
  before_action -> { doorkeeper_authorize! :follow, :'read:blocks' }
  before_action :require_user!
  after_action :insert_pagination_headers

  respond_to :json

  def index
    @accounts = load_accounts
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  private

  def load_accounts
    paginated_blocks.map(&:target_account)
  end

  def paginated_blocks
    @paginated_blocks ||= Block.eager_load(target_account: :account_stat)
                               .where(account: current_account)
                               .paginate_by_max_id(
                                 limit_param(DEFAULT_ACCOUNTS_LIMIT),
                                 params[:max_id],
                                 params[:since_id]
                               )
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    if records_continue?
      api_v1_blocks_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless paginated_blocks.empty?
      api_v1_blocks_url pagination_params(since_id: pagination_since_id)
    end
  end

  def pagination_max_id
    paginated_blocks.last.id
  end

  def pagination_since_id
    paginated_blocks.first.id
  end

  def records_continue?
    paginated_blocks.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end
end
