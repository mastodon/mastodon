# frozen_string_literal: true

class ActivityPub::FollowersSynchronizationsController < ActivityPub::BaseController
  vary_by -> { 'Signature' if authorized_fetch_mode? }

  before_action :require_account_signature!
  before_action :set_items

  def show
    expires_in 0, public: false
    render json: collection_presenter,
           serializer: ActivityPub::CollectionSerializer,
           adapter: ActivityPub::Adapter,
           content_type: 'application/activity+json'
  end

  private

  def uri_prefix
    signed_request_account.uri[Account::URL_PREFIX_RE]
  end

  def set_items
    @items = @account.followers.matches_uri_prefix(uri_prefix).pluck(:uri)
  end

  def collection_presenter
    ActivityPub::CollectionPresenter.new(
      id: account_followers_synchronization_url(@account),
      type: :ordered,
      items: @items
    )
  end
end
