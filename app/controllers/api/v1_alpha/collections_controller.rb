# frozen_string_literal: true

class Api::V1Alpha::CollectionsController < Api::BaseController
  rescue_from ActiveRecord::RecordInvalid, Mastodon::ValidationError do |e|
    render json: { error: ValidationErrorFormatter.new(e).as_json }, status: 422
  end

  before_action :check_feature_enabled

  before_action -> { doorkeeper_authorize! :write, :'write:collections' }, only: [:create]

  before_action :require_user!

  def create
    @collection = CreateCollectionService.new.call(collection_params, current_user.account)

    render json: @collection, serializer: REST::CollectionSerializer
  end

  private

  def collection_params
    params.permit(:name, :description, :sensitive, :discoverable, :tag, account_ids: [])
  end

  def check_feature_enabled
    raise ActionController::RoutingError unless Mastodon::Feature.collections_enabled?
  end
end
