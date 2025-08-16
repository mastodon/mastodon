# frozen_string_literal: true

class Api::V1::Statuses::ContextsController < Api::BaseController
  include Authorization
  include AsyncRefreshesConcern

  before_action -> { authorize_if_got_token! :read, :'read:statuses' }
  before_action :set_status

  # This API was originally unlimited and pagination cannot be introduced
  # without breaking backwards-compatibility. Use a relatively high number to
  # cover most conversations as "unlimited", while enforcing a resource cap
  CONTEXT_LIMIT = 4_096

  # Avoid expensive computation and limit results for logged-out users
  ANCESTORS_LIMIT         = 40
  DESCENDANTS_LIMIT       = 60
  DESCENDANTS_DEPTH_LIMIT = 20

  def show
    cache_if_unauthenticated!

    @context = Context.new(ancestors: loaded_ancestors, descendants: loaded_descendants)

    process_async_refresh!

    render json: @context, serializer: REST::ContextSerializer, relationships:
  end

  private

  def relationships
    StatusRelationshipsPresenter.new(statuses, current_user&.account_id)
  end

  def process_async_refresh!
    async_refresh = AsyncRefresh.new(refresh_key)

    if async_refresh.running?
      add_async_refresh_header(async_refresh)
    elsif current_account.present? && @status.should_fetch_replies?
      add_async_refresh_header(AsyncRefresh.create(refresh_key))
      queue_fetch_replies_worker_batch
    end
  end

  def queue_fetch_replies_worker_batch
    WorkerBatch.new.within do |batch|
      batch.connect(refresh_key, threshold: 1.0)
      ActivityPub::FetchAllRepliesWorker.perform_async(@status.id, { 'batch_id' => batch.id })
    end
  end

  def refresh_key
    "context:#{@status.id}:refresh"
  end

  def statuses
    [@status] + @context.ancestors + @context.descendants
  end

  def loaded_ancestors
    preload_collection(ancestors_results, Status)
  end

  def loaded_descendants
    preload_collection(descendants_results, Status)
  end

  def ancestors_results
    @status.in_reply_to_id.nil? ? [] : @status.ancestors(ancestors_limit, current_account)
  end

  def descendants_results
    @status.descendants(descendants_limit, current_account, descendants_depth_limit)
  end

  def ancestors_limit
    current_account.present? ? CONTEXT_LIMIT : ANCESTORS_LIMIT
  end

  def descendants_limit
    current_account.present? ? CONTEXT_LIMIT : DESCENDANTS_LIMIT
  end

  def descendants_depth_limit
    current_account.present? ? nil : DESCENDANTS_DEPTH_LIMIT
  end

  def set_status
    @status = Status.find(params[:status_id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end
end
