# frozen_string_literal: true

class Api::V1::StatusesController < ApiController
  before_action -> { doorkeeper_authorize! :read }, except: [:create, :destroy, :reblog, :unreblog, :favourite, :unfavourite]
  before_action -> { doorkeeper_authorize! :write }, only:  [:create, :destroy, :reblog, :unreblog, :favourite, :unfavourite]
  before_action :require_user!, except: [:show, :context, :reblogged_by, :favourited_by]
  before_action :set_status, only:      [:show, :context, :reblogged_by, :favourited_by]

  respond_to :json

  def show
  end

  def context
    @context = OpenStruct.new(ancestors: @status.ancestors(current_account), descendants: @status.descendants(current_account))
    statuses = [@status] + @context[:ancestors] + @context[:descendants]

    set_maps(statuses)
    set_counters_maps(statuses)
  end

  def reblogged_by
    results   = @status.reblogs.paginate_by_max_id(DEFAULT_ACCOUNTS_LIMIT, params[:max_id], params[:since_id])
    accounts  = Account.where(id: results.map(&:account_id)).map { |a| [a.id, a] }.to_h
    @accounts = results.map { |r| accounts[r.account_id] }

    set_account_counters_maps(@accounts)

    next_path = reblogged_by_api_v1_status_url(max_id: results.last.id)    if results.size == DEFAULT_ACCOUNTS_LIMIT
    prev_path = reblogged_by_api_v1_status_url(since_id: results.first.id) unless results.empty?

    set_pagination_headers(next_path, prev_path)

    render action: :accounts
  end

  def favourited_by
    results   = @status.favourites.paginate_by_max_id(DEFAULT_ACCOUNTS_LIMIT, params[:max_id], params[:since_id])
    accounts  = Account.where(id: results.map(&:account_id)).map { |a| [a.id, a] }.to_h
    @accounts = results.map { |f| accounts[f.account_id] }

    set_account_counters_maps(@accounts)

    next_path = favourited_by_api_v1_status_url(max_id: results.last.id)    if results.size == DEFAULT_ACCOUNTS_LIMIT
    prev_path = favourited_by_api_v1_status_url(since_id: results.first.id) unless results.empty?

    set_pagination_headers(next_path, prev_path)

    render action: :accounts
  end

  def create
    @status = PostStatusService.new.call(current_user.account, params[:status], params[:in_reply_to_id].blank? ? nil : Status.find(params[:in_reply_to_id]), params[:media_ids])
    render action: :show
  end

  def destroy
    @status = Status.where(account_id: current_user.account).find(params[:id])
    RemoveStatusService.new.call(@status)
    render_empty
  end

  def reblog
    @status = ReblogService.new.call(current_user.account, Status.find(params[:id]))
    render action: :show
  end

  def unreblog
    RemoveStatusService.new.call(Status.where(account_id: current_user.account, reblog_of_id: params[:id]).first!)
    @status = Status.find(params[:id])
    render action: :show
  end

  def favourite
    @status = FavouriteService.new.call(current_user.account, Status.find(params[:id])).status.reload
    render action: :show
  end

  def unfavourite
    @status = UnfavouriteService.new.call(current_user.account, Status.find(params[:id])).status.reload
    render action: :show
  end

  private

  def set_status
    @status = Status.find(params[:id])
  end
end
