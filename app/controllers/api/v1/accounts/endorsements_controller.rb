# frozen_string_literal: true

class Api::V1::Accounts::EndorsementsController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :read, :'read:accounts' }, only: :index
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, except: :index
  before_action :require_user!, except: :index
  before_action :set_account
  before_action :set_endorsed_accounts, only: :index
  after_action :insert_pagination_headers, only: :index

  def index
    cache_if_unauthenticated!
    render json: @endorsed_accounts, each_serializer: REST::AccountSerializer
  end

  def create
    AccountPin.find_or_create_by!(account: current_account, target_account: @account)
    render json: @account, serializer: REST::RelationshipSerializer, relationships: relationships_presenter
  end

  def destroy
    pin = AccountPin.find_by(account: current_account, target_account: @account)
    pin&.destroy!
    render json: @account, serializer: REST::RelationshipSerializer, relationships: relationships_presenter
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_endorsed_accounts
    @endorsed_accounts = @account.unavailable? ? [] : paginated_endorsed_accounts
  end

  def paginated_endorsed_accounts
    @account.endorsed_accounts.without_suspended.includes(:account_stat, :user).paginate_by_max_id(
      limit_param(DEFAULT_ACCOUNTS_LIMIT),
      params[:max_id],
      params[:since_id]
    )
  end

  def relationships_presenter
    AccountRelationshipsPresenter.new([@account], current_user.account_id)
  end

  def next_path
    api_v1_account_endorsements_url pagination_params(max_id: pagination_max_id) if records_continue?
  end

  def prev_path
    api_v1_account_endorsements_url pagination_params(since_id: pagination_since_id) unless @endorsed_accounts.empty?
  end

  def pagination_collection
    @endorsed_accounts
  end

  def records_continue?
    @endorsed_accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end
end
