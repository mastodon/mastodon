# frozen_string_literal: true

class Api::V1::TimelinesController < ApiController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!, only: [:home, :mentions]

  respond_to :json

  def home
    @statuses = Feed.new(:home, current_account).get(limit_param(DEFAULT_STATUSES_LIMIT), params[:max_id], params[:since_id])
    @statuses = cache_collection(@statuses)

    set_maps(@statuses)
    set_counters_maps(@statuses)
    set_account_counters_maps(@statuses.flat_map { |s| [s.account, s.reblog? ? s.reblog.account : nil] }.compact.uniq)

    next_path = api_v1_home_timeline_url(max_id: @statuses.last.id)    if @statuses.size == limit_param(DEFAULT_STATUSES_LIMIT)
    prev_path = api_v1_home_timeline_url(since_id: @statuses.first.id) unless @statuses.empty?

    set_pagination_headers(next_path, prev_path)

    render action: :index
  end

  def public
    @statuses = Status.as_public_timeline(current_account, params[:local]).paginate_by_max_id(limit_param(DEFAULT_STATUSES_LIMIT), params[:max_id], params[:since_id])
    @statuses = cache_collection(@statuses)

    set_maps(@statuses)
    set_counters_maps(@statuses)
    set_account_counters_maps(@statuses.flat_map { |s| [s.account, s.reblog? ? s.reblog.account : nil] }.compact.uniq)

    next_path = api_v1_public_timeline_url(max_id: @statuses.last.id)    if @statuses.size == limit_param(DEFAULT_STATUSES_LIMIT)
    prev_path = api_v1_public_timeline_url(since_id: @statuses.first.id) unless @statuses.empty?

    set_pagination_headers(next_path, prev_path)

    render action: :index
  end

  def tag
    @tag      = Tag.find_by(name: params[:id].downcase)
    @statuses = @tag.nil? ? [] : Status.as_tag_timeline(@tag, current_account, params[:local]).paginate_by_max_id(limit_param(DEFAULT_STATUSES_LIMIT), params[:max_id], params[:since_id])
    @statuses = cache_collection(@statuses)

    set_maps(@statuses)
    set_counters_maps(@statuses)
    set_account_counters_maps(@statuses.flat_map { |s| [s.account, s.reblog? ? s.reblog.account : nil] }.compact.uniq)

    next_path = api_v1_hashtag_timeline_url(params[:id], max_id: @statuses.last.id)    if @statuses.size == limit_param(DEFAULT_STATUSES_LIMIT)
    prev_path = api_v1_hashtag_timeline_url(params[:id], since_id: @statuses.first.id) unless @statuses.empty?

    set_pagination_headers(next_path, prev_path)

    render action: :index
  end

  private

  def cache_collection(raw)
    super(raw, Status)
  end
end
