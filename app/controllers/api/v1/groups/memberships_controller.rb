# frozen_string_literal: true

class Api::V1::Groups::MembershipsController < Api::BaseController
  before_action -> { authorize_if_got_token! :read, :'read:groups' }
  before_action :set_group
  after_action :insert_pagination_headers

  def index
    @memberships = load_memberships
    render json: @memberships, each_serializer: REST::GroupMembershipSerializer
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def load_memberships
    return [] if hide_results?

    scope = default_memberships
    scope = scope.where(role: params[:role]) if params[:role]
    scope = scope.where.not(account: { id: current_account.excluded_from_timeline_account_ids }) unless current_account.nil?
    scope.merge(paginated_memberships).to_a
  end

  def hide_results?
    @group.suspended? || (@group.hide_members? && !current_account_is_member?)
  end

  def current_account_is_member?
    current_acount.present? && GroupMembership.where(group_id: params[:group_id], account_id: current_account.id).exists?
  end

  def default_memberships
    GroupMembership.joins(:account)
  end

  def paginated_memberships
    @group.memberships.paginate_by_max_id(
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
      api_v1_group_memberships_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless @memberships.empty?
      api_v1_group_memberships_url pagination_params(since_id: pagination_since_id)
    end
  end

  def pagination_max_id
    @memberships.last.id
  end

  def pagination_since_id
    @memberships.first.id
  end

  def records_continue?
    @memberships.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end
end
