# frozen_string_literal: true

class ActivityPub::CollectionsController < ActivityPub::BaseController
  SUPPORTED_COLLECTIONS = %w(featured tags).freeze

  vary_by -> { 'Signature' if authorized_fetch_mode? }

  before_action :require_account_signature!, if: :authorized_fetch_mode?
  before_action :check_authorization
  before_action :set_items
  before_action :set_size
  before_action :set_type

  def show
    expires_in 3.minutes, public: public_fetch_mode?

    if @unauthorized
      render json: collection_presenter, content_type: 'application/activity+json', serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter
    else
      render_with_cache json: collection_presenter, content_type: 'application/activity+json', serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter
    end
  end

  private

  def check_authorization
    # Because in public fetch mode we cache the response, there would be no
    # benefit from performing the check below, since a blocked account or domain
    # would likely be served the cache from the reverse proxy anyway

    @unauthorized = authorized_fetch_mode? && !signed_request_account.nil? && (@account.blocking?(signed_request_account) || (!signed_request_account.domain.nil? && @account.domain_blocking?(signed_request_account.domain)))
  end

  def set_items
    case params[:id]
    when 'featured'
      @items = for_signed_account { preload_collection(@account.pinned_statuses, Status) }
      @items = @items.map { |item| item.distributable? ? item : ActivityPub::TagManager.instance.uri_for(item) }
    when 'tags'
      @items = for_signed_account { @account.featured_tags }
    else
      not_found
    end
  end

  def set_size
    case params[:id]
    when 'featured', 'tags'
      @size = @items.size
    else
      not_found
    end
  end

  def set_type
    case params[:id]
    when 'featured'
      @type = :ordered
    when 'tags'
      @type = :unordered
    else
      not_found
    end
  end

  def collection_presenter
    ActivityPub::CollectionPresenter.new(
      id: ActivityPub::TagManager.instance.collection_uri_for(@account, params[:id]),
      type: @type,
      size: @size,
      items: @items
    )
  end

  def for_signed_account
    if @unauthorized
      []
    else
      yield
    end
  end
end
