# frozen_string_literal: true

class Api::V1::MutesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :follow, :read, :'read:mutes' }
  before_action :require_user!
  after_action :insert_pagination_headers

  def index
    @accounts = load_accounts
    render json: @accounts, each_serializer: REST::MutedAccountSerializer
  end

  private

  def load_accounts
    paginated_mutes.map(&:target_account)
  end

  def paginated_mutes
    @paginated_mutes ||= Mute.eager_load(target_account: [:account_stat, :user])
                             .joins(:target_account)
                             .merge(Account.without_suspended)
                             .where(account: current_account)
                             .paginate_by_max_id(
                               limit_param(DEFAULT_ACCOUNTS_LIMIT),
                               params[:max_id],
                               params[:since_id]
                             )
  end

  def next_path
    api_v1_mutes_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_mutes_url pagination_params(since_id: pagination_since_id) unless paginated_mutes.empty?
  end

  def pagination_collection
    paginated_mutes
  end

  def records_continue?
    paginated_mutes.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end
end
