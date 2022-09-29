# frozen_string_literal: true

class ActivityPub::FollowersSynchronizationsController < ActivityPub::BaseController
  include SignatureVerification
  include AccountOwnedConcern

  before_action :require_account_signature!
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
    signed_request_account.uri[Account::URL_PREFIX_RE]
  end

  def set_items
    @items = @account.followers.where(Account.arel_table[:uri].matches("#{Account.sanitize_sql_like(uri_prefix)}/%", false, true)).or(@account.followers.where(uri: uri_prefix)).pluck(:uri)
  end

  def collection_presenter
    ActivityPub::CollectionPresenter.new(
      id: account_followers_synchronization_url(@account),
      type: :ordered,
      items: @items
    )
  end
end
