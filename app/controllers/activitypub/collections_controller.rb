# frozen_string_literal: true

class ActivityPub::CollectionsController < ActivityPub::BaseController
  include SignatureVerification
  include AccountOwnedConcern

  vary_by -> { 'Signature' if authorized_fetch_mode? }

  before_action :require_account_signature!, if: :authorized_fetch_mode?
  before_action :set_items
  before_action :set_size
  before_action :set_type

  def show
    expires_in 3.minutes, public: public_fetch_mode?
    render_with_cache json: collection_presenter, content_type: 'application/activity+json', serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter
  end

  private

  def set_items
    case params[:id]
    when 'featured'
      @items = for_signed_account { cache_collection(@account.pinned_statuses.not_local_only, Status) }
      @items = @items.map { |item| item.distributable? ? item : ActivityPub::TagManager.instance.uri_for(item) }
    when 'tags'
      @items = for_signed_account { @account.featured_tags }
    when 'devices'
      @items = @account.devices
    else
      not_found
    end
  end

  def set_size
    case params[:id]
    when 'featured', 'devices', 'tags'
      @size = @items.size
    else
      not_found
    end
  end

  def set_type
    case params[:id]
    when 'featured'
      @type = :ordered
    when 'devices', 'tags'
      @type = :unordered
    else
      not_found
    end
  end

  def collection_presenter
    ActivityPub::CollectionPresenter.new(
      id: account_collection_url(@account, params[:id]),
      type: @type,
      size: @size,
      items: @items
    )
  end

  def for_signed_account
    # Because in public fetch mode we cache the response, there would be no
    # benefit from performing the check below, since a blocked account or domain
    # would likely be served the cache from the reverse proxy anyway

    if authorized_fetch_mode? && !signed_request_account.nil? && (@account.blocking?(signed_request_account) || (!signed_request_account.domain.nil? && @account.domain_blocking?(signed_request_account.domain)))
      []
    else
      yield
    end
  end
end
