# frozen_string_literal: true

class Api::V1::Statuses::ReblogsController < Api::BaseController
  include Authorization
  include Redisable
  include Lockable

  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }
  before_action :require_user!
  before_action :set_reblog, only: [:create]

  override_rate_limit_headers :create, family: :statuses

  def create
    with_redis_lock("reblog:#{current_account.id}:#{@reblog.id}") do
      @status = ReblogService.new.call(current_account, @reblog, reblog_params)
    end

    render json: @status, serializer: REST::StatusSerializer
  end

  def destroy
    @status = current_account.statuses.find_by(reblog_of_id: params[:status_id])

    if @status
      authorize @status, :unreblog?
      @reblog = @status.reblog
      count = [@reblog.reblogs_count - 1, 0].max
      @status.discard
      RemovalWorker.perform_async(@status.id)
    else
      @reblog = Status.find(params[:status_id])
      count = @reblog.reblogs_count
      authorize @reblog, :show?
    end

    relationships = StatusRelationshipsPresenter.new([@status], current_account.id, reblogs_map: { @reblog.id => false }, attributes_map: { @reblog.id => { reblogs_count: count } })
    render json: @reblog, serializer: REST::StatusSerializer, relationships: relationships
  rescue Mastodon::NotPermittedError
    not_found
  end

  private

  def set_reblog
    @reblog = Status.find(params[:status_id])
    authorize @reblog, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end

  def reblog_params
    params.permit(:visibility)
  end
end
