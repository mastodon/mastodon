# frozen_string_literal: true

class CollectionsController < ApplicationController
  include WebAppControllerConcern
  include SignatureAuthentication
  include Authorization
  include AccountOwnedConcern

  vary_by -> { public_fetch_mode? ? 'Accept, Accept-Language, Cookie' : 'Accept, Accept-Language, Cookie, Signature' }

  before_action :check_feature_enabled
  before_action :require_account_signature!, only: :show, if: -> { request.format == :json && authorized_fetch_mode? }
  before_action :set_collection

  skip_around_action :set_locale, if: -> { request.format == :json }
  skip_before_action :require_functional!, only: :show, unless: :limited_federation_mode?

  def show
    respond_to do |format|
      # TODO: format.html

      format.json do
        expires_in expiration_duration, public: true if public_fetch_mode?
        render_with_cache json: @collection, content_type: 'application/activity+json', serializer: ActivityPub::FeaturedCollectionSerializer, adapter: ActivityPub::Adapter
      end
    end
  end

  private

  def set_collection
    @collection = @account.collections.find(params[:id])
    authorize @collection, :show?
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    not_found
  end

  def expiration_duration
    recently_updated = @collection.updated_at > 15.minutes.ago
    recently_updated ? 30.seconds : 5.minutes
  end

  def check_feature_enabled
    raise ActionController::RoutingError unless Mastodon::Feature.collections_enabled?
  end
end
