# frozen_string_literal: true

class Api::V2::Notifications::AccountsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:notifications' }
  before_action :require_user!
  before_action :set_notifications!
  after_action :insert_pagination_headers, only: :index

  def index
    @accounts = load_accounts
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  private

  def load_accounts
    @paginated_notifications.map(&:from_account)
  end

  def set_notifications!
    @paginated_notifications = begin
      current_account
        .notifications
        .without_suspended
        .where(group_key: params[:notification_group_key])
        .includes(from_account: [:account_stat, :user])
        .paginate_by_max_id(
          limit_param(DEFAULT_ACCOUNTS_LIMIT),
          params[:max_id],
          params[:since_id]
        )
    end
  end

  def next_path
    api_v2_notification_accounts_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v2_notification_accounts_url pagination_params(min_id: pagination_since_id) unless @paginated_notifications.empty?
  end

  def pagination_collection
    @paginated_notifications
  end

  def records_continue?
    @paginated_notifications.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end
end
