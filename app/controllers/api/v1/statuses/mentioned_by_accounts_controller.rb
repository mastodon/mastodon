# frozen_string_literal: true

class Api::V1::Statuses::MentionedByAccountsController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }
  before_action :set_status
  after_action :insert_pagination_headers

  def index
    @accounts = load_accounts
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  private

  def load_accounts
    scope = default_accounts
    scope.merge(paginated_mentions).to_a
  end

  def default_accounts
    Account
      .includes(:mentions, :account_stat)
      .references(:mentions)
      .where(mentions: { status_id: @status.id, silent: true })
  end

  def paginated_mentions
    Mention.paginate_by_max_id(
      limit_param(DEFAULT_ACCOUNTS_LIMIT),
      params[:max_id],
      params[:since_id]
    )
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    api_v1_status_mentioned_by_index_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_status_mentioned_by_index_url pagination_params(since_id: pagination_since_id) unless @accounts.empty?
  end

  def pagination_max_id
    @accounts.last.mentions.last.id
  end

  def pagination_since_id
    @accounts.first.mentions.first.id
  end

  def records_continue?
    @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end

  def set_status
    @status = Status.find(params[:status_id])
    authorize @status, :show_mentions?
  rescue Mastodon::NotPermittedError
    not_found
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end
end
