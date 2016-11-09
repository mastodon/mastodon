class Api::V1::TimelinesController < ApiController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!, only: [:home, :mentions]

  respond_to :json

  def home
    @statuses = Feed.new(:home, current_account).get(DEFAULT_STATUSES_LIMIT, params[:max_id], params[:since_id]).to_a

    set_maps(@statuses)

    next_path = api_v1_home_timeline_url(max_id: @statuses.last.id)    if @statuses.size == DEFAULT_STATUSES_LIMIT
    prev_path = api_v1_home_timeline_url(since_id: @statuses.first.id) if @statuses.size > 0

    set_pagination_headers(next_path, prev_path)

    render action: :index
  end

  def mentions
    @statuses = Feed.new(:mentions, current_account).get(DEFAULT_STATUSES_LIMIT, params[:max_id], params[:since_id]).to_a

    set_maps(@statuses)

    next_path = api_v1_mentions_timeline_url(max_id: @statuses.last.id)    if @statuses.size == DEFAULT_STATUSES_LIMIT
    prev_path = api_v1_mentions_timeline_url(since_id: @statuses.first.id) if @statuses.size > 0

    set_pagination_headers(next_path, prev_path)

    render action: :index
  end

  def public
    @statuses = Status.as_public_timeline(current_account).paginate_by_max_id(DEFAULT_STATUSES_LIMIT, params[:max_id], params[:since_id]).to_a

    set_maps(@statuses)

    next_path = api_v1_public_timeline_url(max_id: @statuses.last.id)    if @statuses.size == DEFAULT_STATUSES_LIMIT
    prev_path = api_v1_public_timeline_url(since_id: @statuses.first.id) if @statuses.size > 0

    set_pagination_headers(next_path, prev_path)

    render action: :index
  end

  def tag
    @tag      = Tag.find_by(name: params[:id].downcase)
    @statuses = @tag.nil? ? [] : Status.as_tag_timeline(@tag, current_account).paginate_by_max_id(DEFAULT_STATUSES_LIMIT, params[:max_id], params[:since_id]).to_a

    set_maps(@statuses)

    next_path = api_v1_hashtag_timeline_url(params[:id], max_id: @statuses.last.id)    if @statuses.size == DEFAULT_STATUSES_LIMIT
    prev_path = api_v1_hashtag_timeline_url(params[:id], since_id: @statuses.first.id) if @statuses.size > 0

    set_pagination_headers(next_path, prev_path)

    render action: :index
  end
end
