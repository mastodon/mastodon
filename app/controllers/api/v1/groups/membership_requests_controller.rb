# frozen_string_literal: true

class Api::V1::Groups::MembershipRequestsController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :read, :'read:groups' }, only: :index
  before_action -> { authorize_if_got_token! :write, :'write:groups' }, except: :index
  before_action :set_group, only: :index
  before_action :set_membership_request, except: :index
  after_action :insert_pagination_headers, only: :index

  def index
    @accounts = load_accounts
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  def accept
    authorize @membership_request, :accept?
    AuthorizeMembershipService.new.call(@membership_request)
    render_empty
  end

  def reject
    authorize @membership_request, :reject?
    RejectMembershipService.new.call(@membership_request)
    render_empty
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
    authorize @group, :manage_requests?
  end

  def set_membership_request
    @membership_request = GroupMembershipRequest.find_by(group_id: params[:group_id], account_id: params[:id])
    return not_found if @membership_request.nil?
  end

  def load_accounts
    scope = default_accounts
    scope = scope.where.not(id: current_account.excluded_from_timeline_account_ids) unless current_account.nil? #TODO: maybe not filter this?
    scope.merge(paginated_membership_requests).to_a
  end

  def default_accounts
    Account.without_suspended.includes(:group_membership_requests).references(:group_membership_requests)
  end

  def paginated_membership_requests
    @group.membership_requests.paginate_by_max_id(
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
      api_v1_group_membership_requests_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless @accounts.empty?
      api_v1_group_membership_requests_url pagination_params(since_id: pagination_since_id)
    end
  end

  def pagination_max_id
    @accounts.last.group_membership_requests.last.id
  end

  def pagination_since_id
    @accounts.first.group_membership_requests.first.id
  end

  def records_continue?
    @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end
end
