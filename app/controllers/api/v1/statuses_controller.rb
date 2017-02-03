# frozen_string_literal: true

class Api::V1::StatusesController < ApiController
  before_action -> { doorkeeper_authorize! :read }, except: [:create, :destroy, :reblog, :unreblog, :favourite, :unfavourite]
  before_action -> { doorkeeper_authorize! :write }, only:  [:create, :destroy, :reblog, :unreblog, :favourite, :unfavourite]
  before_action :require_user!, except: [:show, :context, :card, :reblogged_by, :favourited_by]
  before_action :set_status, only:      [:show, :context, :card, :reblogged_by, :favourited_by]

  respond_to :json

  def show
    cached  = Rails.cache.read(@status.cache_key)
    @status = cached unless cached.nil?
  end

  def context
    ancestors_results   = @status.in_reply_to_id.nil? ? [] : @status.ancestors(current_account)
    descendants_results = @status.descendants(current_account)
    loaded_ancestors    = cache_collection(ancestors_results, Status)
    loaded_descendants  = cache_collection(descendants_results, Status)

    @context = OpenStruct.new(ancestors: loaded_ancestors, descendants: loaded_descendants)
    statuses = [@status] + @context[:ancestors] + @context[:descendants]

    set_maps(statuses)
    set_counters_maps(statuses)
  end

  def card
    @card = PreviewCard.find_by(status: @status)
    render_empty if @card.nil?
  end

  def reblogged_by
    results   = @status.reblogs.paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id])
    accounts  = Account.where(id: results.map(&:account_id)).map { |a| [a.id, a] }.to_h
    @accounts = results.map { |r| accounts[r.account_id] }

    set_account_counters_maps(@accounts)

    next_path = reblogged_by_api_v1_status_url(max_id: results.last.id)    if results.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
    prev_path = reblogged_by_api_v1_status_url(since_id: results.first.id) unless results.empty?

    set_pagination_headers(next_path, prev_path)

    render action: :accounts
  end

  def favourited_by
    results   = @status.favourites.paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id])
    accounts  = Account.where(id: results.map(&:account_id)).map { |a| [a.id, a] }.to_h
    @accounts = results.map { |f| accounts[f.account_id] }

    set_account_counters_maps(@accounts)

    next_path = favourited_by_api_v1_status_url(max_id: results.last.id)    if results.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
    prev_path = favourited_by_api_v1_status_url(since_id: results.first.id) unless results.empty?

    set_pagination_headers(next_path, prev_path)

    render action: :accounts
  end

  def create
    begin
      @status = PostStatusService.new.call(current_user.account, params[:status], params[:in_reply_to_id].blank? ? nil : Status.find(params[:in_reply_to_id]), media_ids: params[:media_ids],
                                                                                                                                                               sensitive: params[:sensitive],
                                                                                                                                                               spoiler_text: params[:spoiler_text],
                                                                                                                                                               visibility: params[:visibility],
                                                                                                                                                               application: doorkeeper_token.application)
    rescue Mastodon::NotPermitted => e
       render json: {error: e.message}, status: 422
       return
    end
    render action: :show
  end

  def destroy
    @status = Status.where(account_id: current_user.account).find(params[:id])
    RemovalWorker.perform_async(@status.id)
    render_empty
  end

  def reblog
    @status = ReblogService.new.call(current_user.account, Status.find(params[:id]))
    render action: :show
  end

  def unreblog
    reblog         = Status.where(account_id: current_user.account, reblog_of_id: params[:id]).first!
    @status        = reblog.reblog
    @reblogged_map = { @status.id => false }

    RemovalWorker.perform_async(reblog.id)

    render action: :show
  end

  def favourite
    @status = FavouriteService.new.call(current_user.account, Status.find(params[:id])).status.reload
    render action: :show
  end

  def unfavourite
    @status         = Status.find(params[:id])
    @favourited_map = { @status.id => false }

    UnfavouriteWorker.perform_async(current_user.account_id, @status.id)

    render action: :show
  end

  private

  def set_status
    @status = Status.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @status.permitted?(current_account)
  end
end
