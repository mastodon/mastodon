# frozen_string_literal: true

class ActivityPub::FeatureAuthorizationsController < ActivityPub::BaseController
  include Authorization

  vary_by -> { 'Signature' if authorized_fetch_mode? }

  before_action :require_account_signature!, if: :authorized_fetch_mode?
  before_action :set_collection_item

  def show
    expires_in 30.seconds, public: true if public_fetch_mode?
    render json: @collection_item, serializer: ActivityPub::FeatureAuthorizationSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
  end

  private

  def pundit_user
    signed_request_account
  end

  def set_collection_item
    @collection_item = @account.collection_items.accepted.find(params[:id])

    authorize @collection_item.collection, :show?
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    not_found
  end
end
