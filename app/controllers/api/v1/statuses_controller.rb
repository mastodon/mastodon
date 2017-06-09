# frozen_string_literal: true

class Api::V1::StatusesController < Api::BaseController
  include Authorization

  before_action :authorize_if_got_token, except:            [:create, :destroy]
  before_action -> { doorkeeper_authorize! :write }, only:  [:create, :destroy]
  before_action :require_user!, except:  [:show, :context, :card]
  before_action :set_status, only:       [:show, :context, :card]

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
    authorize @status, :destroy?

    RemovalWorker.perform_async(@status.id)

    render_empty
  end

  private

  def set_status
    @status = Status.find(params[:id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    # Reraise in order to get a 404 instead of a 403 error code
    raise ActiveRecord::RecordNotFound
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
