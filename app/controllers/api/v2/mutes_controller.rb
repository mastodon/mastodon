# frozen_string_literal: true

class Api::V2::MutesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :follow }
  before_action :require_user!
  after_action :insert_pagination_headers

  respond_to :json

  def index
    @mutes = load_mutes
    render json: @mutes, each_serializer: REST::MuteSerializer
  end

  def load_mutes
    paginated_mutes.includes(:target_account).to_a
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
    url_for pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    url_for pagination_params(since_id: pagination_since_id) unless @mutes.empty?
  end

  def pagination_max_id
    @mutes.last.id
  end

  def pagination_since_id
    @mutes.first.id
  end

  def records_continue?
    @mutes.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end
end
