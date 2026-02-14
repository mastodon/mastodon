# frozen_string_literal: true

class Api::V1Alpha::CollectionItemsController < Api::BaseController
  include Authorization

  before_action :check_feature_enabled

  before_action -> { doorkeeper_authorize! :write, :'write:collections' }

  before_action :require_user!

  before_action :set_collection
  before_action :set_account, only: [:create]
  before_action :set_collection_item, only: [:destroy]

  after_action :verify_authorized

  def create
    authorize @collection, :update?
    authorize @account, :feature?

    @item = AddAccountToCollectionService.new.call(@collection, @account)

    render json: @item, serializer: REST::CollectionItemSerializer, adapter: :json
  end

  def destroy
    authorize @collection, :update?

    DeleteCollectionItemService.new.call(@collection_item)

    head 200
  end

  private

  def set_collection
    @collection = Collection.find(params[:collection_id])
  end

  def set_account
    return render(json: { error: '`account_id` parameter is missing' }, status: 422) if params[:account_id].blank?

    @account = Account.find(params[:account_id])
  end

  def set_collection_item
    @collection_item = @collection.collection_items.find(params[:id])
  end

  def check_feature_enabled
    raise ActionController::RoutingError unless Mastodon::Feature.collections_enabled?
  end
end
