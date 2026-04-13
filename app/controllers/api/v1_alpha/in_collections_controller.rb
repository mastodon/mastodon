# frozen_string_literal: true

class Api::V1Alpha::InCollectionsController < Api::BaseController
  include Authorization

  DEFAULT_COLLECTIONS_LIMIT = 40

  before_action :check_feature_enabled

  before_action -> { authorize_if_got_token! :read, :'read:collections' }, only: [:index]

  before_action :require_user!
  before_action :set_collections, only: [:index]

  after_action :insert_pagination_headers, only: [:index]

  after_action :verify_authorized

  def index
    cache_if_unauthenticated!
    authorize current_account, :index_collections?

    render json: @collections, each_serializer: REST::CollectionSerializer, adapter: :json
  rescue Mastodon::NotPermittedError
    render json: { collections: [] }
  end

  private

  def set_collections
    @collections = current_account.featured_in_collections
      .with_tag
      .offset(offset_param)
      .limit(limit_param(DEFAULT_COLLECTIONS_LIMIT))
  end

  def check_feature_enabled
    raise ActionController::RoutingError unless Mastodon::Feature.collections_enabled?
  end

  def next_path
    return unless records_continue?

    api_v1_alpha_in_collections_url(pagination_params(offset: offset_param + limit_param(DEFAULT_COLLECTIONS_LIMIT)))
  end

  def prev_path
    return if offset_param.zero?

    api_v1_alpha_in_collections_url(pagination_params(offset: offset_param - limit_param(DEFAULT_COLLECTIONS_LIMIT)))
  end

  def records_continue?
    ((offset_param * limit_param(DEFAULT_COLLECTIONS_LIMIT)) + @collections.size) < current_account.featured_in_collections.size
  end

  def offset_param
    params[:offset].to_i
  end
end
