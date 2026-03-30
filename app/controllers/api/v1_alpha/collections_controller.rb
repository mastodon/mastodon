# frozen_string_literal: true

class Api::V1Alpha::CollectionsController < Api::BaseController
  include Authorization

  DEFAULT_COLLECTIONS_LIMIT = 40

  rescue_from ActiveRecord::RecordInvalid, Mastodon::ValidationError do |e|
    render json: { error: ValidationErrorFormatter.new(e).as_json }, status: 422
  end

  before_action :check_feature_enabled

  before_action -> { authorize_if_got_token! :read, :'read:collections' }, only: [:index, :show]
  before_action -> { doorkeeper_authorize! :write, :'write:collections' }, only: [:create, :update, :destroy]

  before_action :require_user!, only: [:create, :update, :destroy]

  before_action :set_account, only: [:index]
  before_action :set_collections, only: [:index]
  before_action :set_collection, only: [:show, :update, :destroy]

  after_action :insert_pagination_headers, only: [:index]

  after_action :verify_authorized

  def index
    cache_if_unauthenticated!
    authorize @account, :index_collections?

    render json: @collections, each_serializer: REST::CollectionSerializer, adapter: :json
  rescue Mastodon::NotPermittedError
    render json: { collections: [] }
  end

  def show
    cache_if_unauthenticated!
    authorize @collection, :show?

    render json: @collection, serializer: REST::CollectionWithAccountsSerializer
  end

  def create
    authorize Collection, :create?

    @collection = CreateCollectionService.new.call(collection_creation_params, current_user.account)

    render json: @collection, serializer: REST::CollectionSerializer, adapter: :json
  end

  def update
    authorize @collection, :update?

    UpdateCollectionService.new.call(@collection, collection_update_params)

    render json: @collection, serializer: REST::CollectionSerializer, adapter: :json
  end

  def destroy
    authorize @collection, :destroy?

    DeleteCollectionService.new.call(@collection)

    head 200
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end

  def set_collections
    @collections = @account.collections
      .with_tag
      .order(created_at: :desc)
      .offset(offset_param)
      .limit(limit_param(DEFAULT_COLLECTIONS_LIMIT))
    @collections = @collections.discoverable unless @account == current_account
  end

  def set_collection
    @collection = Collection.find(params[:id])
  end

  def collection_creation_params
    params.permit(:name, :description, :language, :sensitive, :discoverable, :tag_name, account_ids: [])
  end

  def collection_update_params
    params.permit(:name, :description, :language, :sensitive, :discoverable, :tag_name)
  end

  def check_feature_enabled
    raise ActionController::RoutingError unless Mastodon::Feature.collections_enabled?
  end

  def next_path
    return unless records_continue?

    api_v1_alpha_account_collections_url(@account, pagination_params(offset: offset_param + limit_param(DEFAULT_COLLECTIONS_LIMIT)))
  end

  def prev_path
    return if offset_param.zero?

    api_v1_alpha_account_collections_url(@account, pagination_params(offset: offset_param - limit_param(DEFAULT_COLLECTIONS_LIMIT)))
  end

  def records_continue?
    ((offset_param * limit_param(DEFAULT_COLLECTIONS_LIMIT)) + @collections.size) < @account.collections.size
  end

  def offset_param
    params[:offset].to_i
  end
end
