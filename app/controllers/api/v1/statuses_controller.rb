# frozen_string_literal: true

class Api::V1::StatusesController < Api::BaseController
  include Authorization

  before_action -> { authorize_if_got_token! :read, :'read:statuses' }, except: [:create, :update, :destroy]
  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }, only:   [:create, :update, :destroy]
  before_action :require_user!, except:      [:index, :show, :context]
  before_action :set_statuses, only:         [:index]
  before_action :set_status, only:           [:show, :context]
  before_action :set_thread, only:           [:create]
  before_action :check_statuses_limit, only: [:index]

  override_rate_limit_headers :create, family: :statuses
  override_rate_limit_headers :update, family: :statuses

  # This API was originally unlimited, pagination cannot be introduced without
  # breaking backwards-compatibility. Arbitrarily high number to cover most
  # conversations as quasi-unlimited, it would be too much work to render more
  # than this anyway
  CONTEXT_LIMIT = 4_096

  # This remains expensive and we don't want to show everything to logged-out users
  ANCESTORS_LIMIT         = 40
  DESCENDANTS_LIMIT       = 60
  DESCENDANTS_DEPTH_LIMIT = 20

  def index
    @statuses = preload_collection(@statuses, Status)
    render json: @statuses, each_serializer: REST::StatusSerializer
  end

  def show
    cache_if_unauthenticated!
    @status = preload_collection([@status], Status).first
    render json: @status, serializer: REST::StatusSerializer
  end

  def context
    cache_if_unauthenticated!

    ancestors_limit         = CONTEXT_LIMIT
    descendants_limit       = CONTEXT_LIMIT
    descendants_depth_limit = nil

    if current_account.nil?
      ancestors_limit         = ANCESTORS_LIMIT
      descendants_limit       = DESCENDANTS_LIMIT
      descendants_depth_limit = DESCENDANTS_DEPTH_LIMIT
    end

    ancestors_results   = @status.in_reply_to_id.nil? ? [] : @status.ancestors(ancestors_limit, current_account)
    descendants_results = @status.descendants(descendants_limit, current_account, descendants_depth_limit)
    loaded_ancestors    = preload_collection(ancestors_results, Status)
    loaded_descendants  = preload_collection(descendants_results, Status)

    @context = Context.new(ancestors: loaded_ancestors, descendants: loaded_descendants)
    statuses = [@status] + @context.ancestors + @context.descendants

    render json: @context, serializer: REST::ContextSerializer, relationships: StatusRelationshipsPresenter.new(statuses, current_user&.account_id)
  end

  def create
    @status = PostStatusService.new.call(
      current_user.account,
      text: status_params[:status],
      thread: @thread,
      media_ids: status_params[:media_ids],
      sensitive: status_params[:sensitive],
      spoiler_text: status_params[:spoiler_text],
      visibility: status_params[:visibility],
      language: status_params[:language],
      scheduled_at: status_params[:scheduled_at],
      application: doorkeeper_token.application,
      poll: status_params[:poll],
      content_type: status_params[:content_type],
      allowed_mentions: status_params[:allowed_mentions],
      idempotency: request.headers['Idempotency-Key'],
      with_rate_limit: true
    )

    render json: @status, serializer: serializer_for_status
  rescue PostStatusService::UnexpectedMentionsError => e
    render json: unexpected_accounts_error_json(e), status: 422
  end

  def update
    @status = Status.where(account: current_account).find(params[:id])
    authorize @status, :update?

    UpdateStatusService.new.call(
      @status,
      current_account.id,
      text: status_params[:status],
      media_ids: status_params[:media_ids],
      media_attributes: status_params[:media_attributes],
      sensitive: status_params[:sensitive],
      language: status_params[:language],
      spoiler_text: status_params[:spoiler_text],
      poll: status_params[:poll],
      content_type: status_params[:content_type]
    )

    render json: @status, serializer: REST::StatusSerializer
  end

  def destroy
    @status = Status.where(account: current_account).find(params[:id])
    authorize @status, :destroy?

    @status.discard_with_reblogs
    StatusPin.find_by(status: @status)&.destroy
    @status.account.statuses_count = @status.account.statuses_count - 1
    json = render_to_body json: @status, serializer: REST::StatusSerializer, source_requested: true

    RemovalWorker.perform_async(@status.id, { 'redraft' => true })

    render json: json
  end

  private

  def set_statuses
    @statuses = Status.permitted_statuses_from_ids(status_ids, current_account)
  end

  def set_status
    @status = Status.find(params[:id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end

  def set_thread
    @thread = Status.find(status_params[:in_reply_to_id]) if status_params[:in_reply_to_id].present?
    authorize(@thread, :show?) if @thread.present?
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    render json: { error: I18n.t('statuses.errors.in_reply_not_found') }, status: 404
  end

  def check_statuses_limit
    raise(Mastodon::ValidationError) if status_ids.size > DEFAULT_STATUSES_LIMIT
  end

  def status_ids
    Array(statuses_params[:id]).uniq.map(&:to_i)
  end

  def statuses_params
    params.permit(id: [])
  end

  def status_params
    params.permit(
      :status,
      :in_reply_to_id,
      :sensitive,
      :spoiler_text,
      :visibility,
      :language,
      :scheduled_at,
      :content_type,
      allowed_mentions: [],
      media_ids: [],
      media_attributes: [
        :id,
        :thumbnail,
        :description,
        :focus,
      ],
      poll: [
        :multiple,
        :hide_totals,
        :expires_in,
        options: [],
      ]
    )
  end

  def serializer_for_status
    @status.is_a?(ScheduledStatus) ? REST::ScheduledStatusSerializer : REST::StatusSerializer
  end

  def unexpected_accounts_error_json(error)
    {
      error: error.message,
      unexpected_accounts: serialized_accounts(error.accounts),
    }
  end

  def serialized_accounts(accounts)
    ActiveModel::Serializer::CollectionSerializer.new(accounts, serializer: REST::AccountSerializer)
  end
end
