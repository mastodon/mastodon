#to do: modify this to fix pagination
# frozen_string_literal: true

class Api::V1::Timelines::HomeController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read, :'read:statuses' }, only: [:show]
  before_action :require_user!, only: [:show]
  after_action :insert_pagination_headers, unless: -> { @statuses.empty? }

  def show
    Rails.logger.info "home_feed.rb Entering show action with params: #{params.inspect}"
  
    @statuses = load_statuses
    Rails.logger.info "home_feed.rb Loaded statuses: #{@statuses.map(&:id).inspect} #{@statuses}" unless @statuses.nil?

    Rails.logger.info "home_feed.rb Rendered statuses with status code: #{account_home_feed.regenerating? ? 206 : 200}"
  
    render json: @statuses,
           each_serializer: REST::StatusSerializer,
           relationships: StatusRelationshipsPresenter.new(@statuses, current_user&.account_id),
           status: account_home_feed.regenerating? ? 206 : 200
  end

  private

  def load_statuses
    x = cached_home_statuses
    Rails.logger.info "home_feed.rb home_controller load_statuses #{x}"
    x
  end

  def cached_home_statuses

    x = cache_collection home_statuses, Status

    Rails.logger.info "home_feed.rb home_controller cached_home_statuses #{x}"
    x
  end

  def home_statuses
    x = account_home_feed.get(
      limit_param(DEFAULT_STATUSES_LIMIT),
      params[:max_id],
      params[:since_id],
      params[:min_id]
    )
    Rails.logger.info "home_feed.rb home_controller home_statuses #{x}"

    account_home_feed.get(
      limit_param(DEFAULT_STATUSES_LIMIT),
      params[:max_id],
      params[:since_id],
      params[:min_id]
    )
  end

  def account_home_feed
    HomeFeed.new(current_account)
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def pagination_params(core_params)
    params.slice(:local, :limit).permit(:local, :limit).merge(core_params)
  end

  def next_path
    api_v1_timelines_home_url pagination_params(max_id: pagination_max_id)
  end

  def prev_path
    api_v1_timelines_home_url pagination_params(min_id: pagination_since_id)
  end

  def pagination_max_id
    @statuses.last.id
  end

  def pagination_since_id
    @statuses.first.id
  end
end
