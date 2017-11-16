# frozen_string_literal: true

class Api::V1::MutesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :follow }
  before_action :require_user!
  after_action :insert_pagination_headers

  respond_to :json

  def index
    @data = @accounts = load_accounts
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  def details
    @data = @mutes = load_mutes
    render json: @mutes, each_serializer: REST::MuteSerializer
  end 

  private

  def load_accounts
    default_accounts.merge(paginated_mutes).to_a
  end

  def default_accounts
    Account.includes(:muted_by).references(:muted_by)
  end

  def load_mutes
    paginated_mutes.includes(:account, :target_account).to_a
  end

  def paginated_mutes
    Mute.where(account: current_account).paginate_by_max_id(
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
      url_for pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless@data.empty?
      url_for pagination_params(since_id: pagination_since_id)
    end
  end

  def pagination_max_id
    if params[:action] == "details"
      @mutes.last.id
    else
      @accounts.last.muted_by_ids.last
    end
  end

  def pagination_since_id
    if params[:action] == "details"
      @mutes.first.id
    else
      @accounts.first.muted_by_ids.first
    end
  end

  def records_continue?
    @data.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end
end
