# frozen_string_literal: true

class Api::V1::StatusesController < ApiController
  before_action :authorize_if_got_token, except:            [:create, :destroy, :reblog, :unreblog, :favourite, :unfavourite, :mute, :unmute]
  before_action -> { doorkeeper_authorize! :write }, only:  [:create, :destroy, :reblog, :unreblog, :favourite, :unfavourite, :mute, :unmute]
  before_action :require_user!, except:  [:show, :context, :card, :reblogged_by, :favourited_by]
  before_action :set_status, only:       [:show, :context, :card, :reblogged_by, :favourited_by, :mute, :unmute]
  before_action :set_conversation, only: [:mute, :unmute]

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
  end

  def card
    @card = PreviewCard.find_by(status: @status)
    render_empty if @card.nil?
  end

  def reblogged_by
    @accounts = Account.includes(:statuses)
                       .references(:statuses)
                       .merge(Status.where(reblog_of_id: @status.id)
                                    .paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id]))
                       .to_a

    next_path = reblogged_by_api_v1_status_url(pagination_params(max_id: @accounts.last.statuses.last.id))     if @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
    prev_path = reblogged_by_api_v1_status_url(pagination_params(since_id: @accounts.first.statuses.first.id)) unless @accounts.empty?

    set_pagination_headers(next_path, prev_path)

    render :accounts
  end

  def favourited_by
    @accounts = Account.includes(:favourites)
                       .references(:favourites)
                       .where(favourites: { status_id: @status.id })
                       .merge(Favourite.paginate_by_max_id(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:max_id], params[:since_id]))
                       .to_a

    next_path = favourited_by_api_v1_status_url(pagination_params(max_id: @accounts.last.favourites.last.id))     if @accounts.size == limit_param(DEFAULT_ACCOUNTS_LIMIT)
    prev_path = favourited_by_api_v1_status_url(pagination_params(since_id: @accounts.first.favourites.first.id)) unless @accounts.empty?

    set_pagination_headers(next_path, prev_path)

    render :accounts
  end

  def create
    @status = PostStatusService.new.call(current_user.account,
                                         status_params[:status],
                                         status_params[:in_reply_to_id].blank? ? nil : Status.find(status_params[:in_reply_to_id]),
                                         media_ids: status_params[:media_ids],
                                         sensitive: status_params[:sensitive],
                                         spoiler_text: status_params[:spoiler_text],
                                         visibility: status_params[:visibility],
                                         application: doorkeeper_token.application,
                                         idempotency: request.headers['Idempotency-Key'])

    render :show
  end

  def destroy
    @status = Status.where(account_id: current_user.account).find(params[:id])
    RemovalWorker.perform_async(@status.id)
    render_empty
  end

  def reblog
    @status = ReblogService.new.call(current_user.account, Status.find(params[:id]))
    render :show
  end

  def unreblog
    reblog       = Status.where(account_id: current_user.account, reblog_of_id: params[:id]).first!
    @status      = reblog.reblog
    @reblogs_map = { @status.id => false }

    RemovalWorker.perform_async(reblog.id)

    render :show
  end

  def favourite
    @status = FavouriteService.new.call(current_user.account, Status.find(params[:id])).status.reload
    render :show
  end

  def unfavourite
    @status         = Status.find(params[:id])
    @favourites_map = { @status.id => false }

    UnfavouriteWorker.perform_async(current_user.account_id, @status.id)

    render :show
  end

  def mute
    current_account.mute_conversation!(@conversation)

    @mutes_map = { @conversation.id => true }

    render :show
  end

  def unmute
    current_account.unmute_conversation!(@conversation)

    @mutes_map = { @conversation.id => false }

    render :show
  end

  private

  def set_status
    @status = Status.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @status.permitted?(current_account)
  end

  def set_conversation
    @conversation = @status.conversation
    raise Mastodon::ValidationError if @conversation.nil?
  end

  def status_params
    params.permit(:status, :in_reply_to_id, :sensitive, :spoiler_text, :visibility, media_ids: [])
  end

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end

  def authorize_if_got_token
    request_token = Doorkeeper::OAuth::Token.from_request(request, *Doorkeeper.configuration.access_token_methods)
    doorkeeper_authorize! :read if request_token
  end
end
