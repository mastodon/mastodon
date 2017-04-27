# frozen_string_literal: true

class Api::Activitypub::OutboxController < ApiController
  before_action :set_account

  respond_to :activitystreams2

  def show
    headers['Access-Control-Allow-Origin'] = '*'

    @statuses = Status.as_outbox_timeline(@account).paginate_by_max_id(limit_param(DEFAULT_STATUSES_LIMIT), params[:max_id], params[:since_id])
    @statuses = cache_collection(@statuses)

    set_maps(@statuses)

    # Since the statuses are in reverse chronological order, last is the lowest ID.
    @next_path = api_activitypub_outbox_url(max_id: @statuses.last.id) if @statuses.size == limit_param(DEFAULT_STATUSES_LIMIT)

    unless @statuses.empty?
      if @statuses.first.id == 1
        @prev_path = api_activitypub_outbox_url
      elsif params[:max_id]
        @prev_path = api_activitypub_outbox_url(since_id: @statuses.first.id)
      end
    end

    @paginated = @next_path || @prev_path

    set_pagination_headers(@next_path, @prev_path)
  end

  private

  def cache_collection(raw)
    super(raw, Status)
  end

  def set_account
    @account = Account.find(params[:id])
  end
end
