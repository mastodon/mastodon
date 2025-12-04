# frozen_string_literal: true

class Api::V1Alpha::CollectionsController < Api::BaseController
  include Authorization

  rescue_from ActiveRecord::RecordInvalid, Mastodon::ValidationError do |e|
    render json: { error: ValidationErrorFormatter.new(e).as_json }, status: 422
  end

  before_action :check_feature_enabled

  before_action -> { doorkeeper_authorize! :write, :'write:collections' }, only: [:create]

  before_action :require_user!, only: [:create]

  after_action :verify_authorized

  def show
    cache_if_unauthenticated!
    @collection = Collection.find(params[:id])
    authorize @collection, :show?

    render json: @collection, serializer: REST::CollectionSerializer
  end

  def create
    authorize Collection, :create?

    @collection = CreateCollectionService.new.call(collection_creation_params, current_user.account)

    render json: @collection, serializer: REST::CollectionSerializer
  end

  def update
    @collection = Collection.find(params[:id])
    authorize @collection, :update?

    @collection.update!(collection_update_params) # TODO: Create a service for this to federate changes

    render json: @collection, serializer: REST::CollectionSerializer
  end

  private

  def collection_creation_params
    params.permit(:name, :description, :sensitive, :discoverable, :tag_name, account_ids: [])
  end

  def collection_update_params
    params.permit(:name, :description, :sensitive, :discoverable, :tag_name)
  end

  def check_feature_enabled
    raise ActionController::RoutingError unless Mastodon::Feature.collections_enabled?
  end
end
