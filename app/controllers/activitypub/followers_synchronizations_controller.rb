# frozen_string_literal: true

class ActivityPub::FollowersSynchronizationsController < ActivityPub::BaseController
  include SignatureVerification
  include AccountOwnedConcern

  before_action :require_signature!
  before_action :set_items
  before_action :set_cache_headers

  def show
    expires_in 0, public: false
    render json: collection_presenter,
           serializer: ActivityPub::CollectionSerializer,
           adapter: ActivityPub::Adapter,
           content_type: 'application/activity+json'
  end

  private

  def uri_prefix
    signed_request_account.uri[/http(s?):\/\/[^\/]+\//]
  end

  def set_items
    @items = @account.followers.where(Account.arel_table[:uri].matches(uri_prefix + '%', false, true)).pluck(:uri)
  end

  def collection_presenter
    ActivityPub::CollectionPresenter.new(
      id: account_followers_synchronization_url(@account),
      type: :ordered,
      items: @items
    )
  end
end
