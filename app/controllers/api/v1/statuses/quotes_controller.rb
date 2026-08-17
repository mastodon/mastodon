# frozen_string_literal: true

class Api::V1::Statuses::QuotesController < Api::V1::Statuses::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:statuses' }, only: :index
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, only: :revoke

  before_action :set_statuses, only: :index

  before_action :set_quote, only: :revoke
  after_action :insert_pagination_headers, only: :index

  def index
    cache_if_unauthenticated!
    render json: @statuses, each_serializer: REST::StatusSerializer
  end

  def revoke
    authorize @quote, :revoke?

    RevokeQuoteService.new.call(@quote)

    render json: @quote.status, serializer: REST::StatusSerializer
  end

  private

  def set_quote
    @quote = @status.quotes.find_by!(status_id: params[:id])
  end

  def set_statuses
    scope = default_statuses
    scope = scope.not_excluded_by_account(current_account) unless current_account.nil?
    @statuses = scope.merge(paginated_quotes).to_a

    # Store next page info before filtering
    @records_continue = @statuses.size == limit_param(DEFAULT_STATUSES_LIMIT)
    @pagination_since_id = @statuses.first.quote.id unless @statuses.empty?
    @pagination_max_id = @statuses.last.quote.id if @records_continue

    if current_account&.id != @status.account_id
      domains = @statuses.filter_map(&:account_domain).uniq
      account_ids = @statuses.map(&:account_id).uniq
      current_account&.preload_relations!(account_ids, domains)
      @statuses.reject! { |status| StatusFilter.new(status, current_account).filtered? }
    end
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

  attr_reader :pagination_max_id, :pagination_since_id

  def records_continue?
    @records_continue
  end
end
