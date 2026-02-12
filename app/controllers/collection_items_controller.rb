# frozen_string_literal: true

class CollectionItemsController < ApplicationController
  include SignatureAuthentication
  include Authorization
  include AccountOwnedConcern

  vary_by -> { public_fetch_mode? ? 'Accept, Accept-Language, Cookie' : 'Accept, Accept-Language, Cookie, Signature' }

  before_action :check_feature_enabled
  before_action :require_account_signature!, if: -> { authorized_fetch_mode? }
  before_action :set_collection_item

  skip_around_action :set_locale
  skip_before_action :require_functional!, unless: :limited_federation_mode?

  def show
    respond_to do |format|
      format.json do
        expires_in(3.minutes, public: public_fetch_mode?)

        render json: @collection_item,
               serializer: ActivityPub::FeaturedItemSerializer,
               adapter: ActivityPub::Adapter,
               content_type: 'application/activity+json'
      end
    end
  end

  private

  def set_collection_item
    @collection_item = @account.curated_collection_items.find(params[:id])
    authorize @collection_item.collection, :show?
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    not_found
  end

  def check_feature_enabled
    raise ActionController::RoutingError unless Mastodon::Feature.collections_enabled?
  end
end
