# frozen_string_literal: true

class ActivityPub::FeaturedCollectionsController < ApplicationController
  include SignatureAuthentication
  include Authorization
  include AccountOwnedConcern

  PER_PAGE = 5

  vary_by -> { public_fetch_mode? ? 'Accept, Accept-Language, Cookie' : 'Accept, Accept-Language, Cookie, Signature' }

  before_action :check_feature_enabled
  before_action :require_account_signature!, if: -> { authorized_fetch_mode? }
  before_action :set_collections

  skip_around_action :set_locale
  skip_before_action :require_functional!, unless: :limited_federation_mode?

  def index
    respond_to do |format|
      format.json do
        expires_in(page_requested? ? 0 : 3.minutes, public: public_fetch_mode?)

        render json: collection_presenter,
               serializer: ActivityPub::CollectionSerializer,
               adapter: ActivityPub::Adapter,
               content_type: 'application/activity+json'
      end
    end
  end

  private

  def set_collections
    authorize @account, :index_collections?
    @collections = @account.collections.page(params[:page]).per(PER_PAGE)
  rescue Mastodon::NotPermittedError
    not_found
  end

  def page_requested?
    params[:page].present?
  end

  def next_page_url
    ap_account_featured_collections_url(@account, page: @collections.next_page) if @collections.respond_to?(:next_page)
  end

  def prev_page_url
    ap_account_featured_collections_url(@account, page: @collections.prev_page) if @collections.respond_to?(:prev_page)
  end

  def collection_presenter
    if page_requested?
      ActivityPub::CollectionPresenter.new(
        id: ap_account_featured_collections_url(@account, page: params.fetch(:page, 1)),
        type: :unordered,
        size: @account.collections.count,
        items: @collections,
        part_of: ap_account_featured_collections_url(@account),
        next: next_page_url,
        prev: prev_page_url
      )
    else
      ActivityPub::CollectionPresenter.new(
        id: ap_account_featured_collections_url(@account),
        type: :unordered,
        size: @account.collections.count,
        first: ap_account_featured_collections_url(@account, page: 1)
      )
    end
  end

  def check_feature_enabled
    raise ActionController::RoutingError unless Mastodon::Feature.collections_enabled?
  end
end
