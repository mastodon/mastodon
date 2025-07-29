# frozen_string_literal: true

class Api::V1::Statuses::QuotesController < Api::V1::Statuses::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:statuses' }, only: :index
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, only: :revoke

  before_action :check_owner!
  before_action :set_quote, only: :revoke
  after_action :insert_pagination_headers, only: :index

  def index
    cache_if_unauthenticated!
    @statuses = load_statuses
    render json: @statuses, each_serializer: REST::StatusSerializer
  end

  def revoke
    authorize @quote, :revoke?

    RevokeQuoteService.new.call(@quote)

    render_empty # TODO: do we want to return something? an updated status?
  end

  private

  def check_owner!
    authorize @status, :list_quotes?
  end

  def set_quote
    @quote = @status.quotes.find_by!(status_id: params[:id])
  end

  def load_statuses
    scope = default_statuses
    scope = scope.not_excluded_by_account(current_account) unless current_account.nil?
    scope.merge(paginated_quotes).to_a
  end

  def default_statuses
    Status.includes(:quote).references(:quote)
  end

  def paginated_quotes
    @status.quotes.accepted.paginate_by_max_id(
      limit_param(DEFAULT_STATUSES_LIMIT),
      params[:max_id],
      params[:since_id]
    )
  end

  def next_path
    api_v1_status_quotes_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_status_quotes_url pagination_params(since_id: pagination_since_id) unless @statuses.empty?
  end

  def pagination_max_id
    @statuses.last.quote.id
  end

  def pagination_since_id
    @statuses.first.quote.id
  end

  def records_continue?
    @statuses.size == limit_param(DEFAULT_STATUSES_LIMIT)
  end
end
