# frozen_string_literal: true

class Api::V1::Groups::BlocksController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :read, :'read:groups' }, only: :show
  before_action -> { authorize_if_got_token! :write, :'write:groups' }, except: :show

  before_action :set_group

  after_action :insert_pagination_headers, only: :show

  def show
    @accounts = load_accounts
    render json: @accounts, each_serializer: REST::AccountSerializer
  end

  def create
    # Check that the user is allowed to kick every use that is going to get banned
    memberships = @group.memberships.where(account_id: account_ids).to_a
    memberships.each { |membership| authorize membership, :revoke? }

    # TODO: logging

    ApplicationRecord.transaction do
      Account.where(id: account_ids).find_each do |account|
        @group.account_blocks.create!(account: account) # TODO: federate
      end

      # Kick existing members that we are banning
      memberships.each(&:destroy) # TODO: federate

      # Cancel existing membershi prequests
      @group.membership_requests.where(account_id: account_ids).destroy_all # TODO: federate
    end

    render_empty
  end

  def destroy
    # TODO: logging
    # TODO: federation

    @group.account_blocks.where(account_id: account_ids).destroy_all

    render_empty
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
    authorize @group, :manage_blocks?
  end

  def load_accounts
    scope = default_accounts
    scope.merge(paginated_group_account_blocks).to_a
  end

  def default_accounts
    Account.without_suspended.includes(:group_account_blocks).references(:group_account_blocks)
  end

  def paginated_group_account_blocks
    @group.account_blocks.paginate_by_max_id(
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
      api_v1_group_blocks_url pagination_params(max_id: pagination_max_id)
    end
  end

  def prev_path
    unless @accounts.empty?
      api_v1_group_blocks_url pagination_params(since_id: pagination_since_id)
    end
  end

  def pagination_max_id
    @accounts.last.group_account_blocks.last.id
  end

  def pagination_since_id
    @accounts.first.group_account_blocks.first.id
  end

  def records_continue?
    @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
  end

  def pagination_params(core_params)
    params.slice(:limit).permit(:limit).merge(core_params)
  end

  def resource_params
    params.permit(account_ids: [])
  end

  def account_ids
    Array(resource_params[:account_ids])
  end
end
