# frozen_string_literal: true

class Api::ActivityPub::OutboxController < Api::BaseController
  before_action :set_account

  respond_to :activitystreams2

  def show
    if params[:max_id] || params[:since_id]
      show_outbox_page
    else
      show_base_outbox
    end
  end

  private

  def show_base_outbox
    @statuses = Status.as_outbox_timeline(@account)
    @statuses = cache_collection(@statuses)

    set_maps(@statuses)

    set_first_last_page(@statuses)

    render :show
  end

  def show_outbox_page
    all_statuses = Status.as_outbox_timeline(@account)
    @statuses = all_statuses.paginate_by_max_id(limit_param(DEFAULT_STATUSES_LIMIT), params[:max_id], params[:since_id])

    all_statuses = cache_collection(all_statuses)
    @statuses = cache_collection(@statuses)

    set_maps(@statuses)

    set_first_last_page(all_statuses)

    @next_page_url = api_activitypub_outbox_url(pagination_params(max_id: @statuses.last.id))    unless @statuses.empty?
    @prev_page_url = api_activitypub_outbox_url(pagination_params(since_id: @statuses.first.id)) unless @statuses.empty?

    @paginated = @next_page_url || @prev_page_url
    @part_of_url = api_activitypub_outbox_url

    set_pagination_headers(@next_page_url, @prev_page_url)

    render :show_page
  end

  def cache_collection(raw)
    super(raw, Status)
  end

  def set_account
    @account = Account.find(params[:id])
  end

  def set_first_last_page(statuses) # rubocop:disable Style/AccessorMethodName
    return if statuses.empty?

    @first_page_url = api_activitypub_outbox_url(max_id: statuses.first.id + 1)
    @last_page_url = api_activitypub_outbox_url(since_id: statuses.last.id - 1)
  end

  def pagination_params(core_params)
    params.permit(:local, :limit).merge(core_params)
  end
end
