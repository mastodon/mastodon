# frozen_string_literal: true

class ActivityPub::FollowersSynchronizationsController < ActivityPub::BaseController
  include SignatureVerification
  include AccountOwnedConcern

  before_action :require_signature!
  before_action :set_items
  before_action :set_cache_headers

  def show
    expires_in 0, public: false
    render json: collection_presenter, content_type: 'application/activity+json', serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter
  end

  private

  def set_items
    @items = @account.followers.where(domain: signed_request_account.domain).pluck(:uri).sort
  end

  def collection_presenter
    ActivityPub::CollectionPresenter.new(
      id: account_followers_synchronization_url(@account),
      type: :ordered,
      items: @items
    )
  end
end
