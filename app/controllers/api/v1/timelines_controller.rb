# frozen_string_literal: true

class Api::V1::TimelinesController < ApiController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!, only: [:home, :mentions]

  respond_to :json

  def home
    @statuses = Feed.new(:home, current_account).get(DEFAULT_STATUSES_LIMIT, params[:max_id], params[:since_id]).to_a

    set_maps(@statuses)
    set_counters_maps(@statuses)
    set_account_counters_maps(@statuses.flat_map { |s| [s.account, s.reblog? ? s.reblog.account : nil] }.compact.uniq)

    next_path = api_v1_home_timeline_url(max_id: @statuses.last.id)    if @statuses.size == DEFAULT_STATUSES_LIMIT
    prev_path = api_v1_home_timeline_url(since_id: @statuses.first.id) unless @statuses.empty?

    set_pagination_headers(next_path, prev_path)

    render action: :index
  end

  def mentions
    @statuses = Feed.new(:mentions, current_account).get(DEFAULT_STATUSES_LIMIT, params[:max_id], params[:since_id]).to_a

    set_maps(@statuses)
    set_counters_maps(@statuses)
    set_account_counters_maps(@statuses.flat_map { |s| [s.account, s.reblog? ? s.reblog.account : nil] }.compact.uniq)

    next_path = api_v1_mentions_timeline_url(max_id: @statuses.last.id)    if @statuses.size == DEFAULT_STATUSES_LIMIT
    prev_path = api_v1_mentions_timeline_url(since_id: @statuses.first.id) unless @statuses.empty?

    set_pagination_headers(next_path, prev_path)

    render action: :index
  end

  def public
    @statuses = Status.as_public_timeline(current_account).paginate_by_max_id(DEFAULT_STATUSES_LIMIT, params[:max_id], params[:since_id]).to_a
    @statuses = cache(@statuses)

    set_maps(@statuses)
    set_counters_maps(@statuses)
    set_account_counters_maps(@statuses.flat_map { |s| [s.account, s.reblog? ? s.reblog.account : nil] }.compact.uniq)

    next_path = api_v1_public_timeline_url(max_id: @statuses.last.id)    if @statuses.size == DEFAULT_STATUSES_LIMIT
    prev_path = api_v1_public_timeline_url(since_id: @statuses.first.id) unless @statuses.empty?

    set_pagination_headers(next_path, prev_path)

    render action: :index
  end

  def tag
    @tag      = Tag.find_by(name: params[:id].downcase)
    @statuses = @tag.nil? ? [] : Status.as_tag_timeline(@tag, current_account).paginate_by_max_id(DEFAULT_STATUSES_LIMIT, params[:max_id], params[:since_id]).to_a
    @statuses = cache(@statuses)

    set_maps(@statuses)
    set_counters_maps(@statuses)
    set_account_counters_maps(@statuses.flat_map { |s| [s.account, s.reblog? ? s.reblog.account : nil] }.compact.uniq)

    next_path = api_v1_hashtag_timeline_url(params[:id], max_id: @statuses.last.id)    if @statuses.size == DEFAULT_STATUSES_LIMIT
    prev_path = api_v1_hashtag_timeline_url(params[:id], since_id: @statuses.first.id) unless @statuses.empty?

    set_pagination_headers(next_path, prev_path)

    render action: :index
  end

  private

  def cache(raw)
    uncached_ids           = []
    cached_keys_with_value = Rails.cache.read_multi(*raw.map(&:cache_key))

    raw.each do |status|
      uncached_ids << status.id unless cached_keys_with_value.key?(status.cache_key)
    end

    unless uncached_ids.empty?
      uncached = Status.where(id: uncached_ids).with_includes.map { |s| [s.id, s] }.to_h

      uncached.values.each do |status|
        Rails.cache.write(status.cache_key, status)
      end
    end

    raw.map { |status| cached_keys_with_value[status.cache_key] || uncached[status.id] }
  end
end
