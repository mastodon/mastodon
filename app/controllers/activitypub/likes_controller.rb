# frozen_string_literal: true

class ActivityPub::LikesController < ActivityPub::BaseController
  include Authorization

  vary_by -> { 'Signature' if authorized_fetch_mode? }

  before_action :require_account_signature!, if: :authorized_fetch_mode?
  before_action :set_status

  def index
    expires_in 0, public: @status.distributable? && public_fetch_mode?
    render json: likes_collection_presenter, serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
  end

  private

  def pundit_user
    signed_request_account
  end

  def set_status
    @status = @account.statuses.find(params[:status_id])
    authorize @status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end

  def likes_collection_presenter
    ActivityPub::CollectionPresenter.new(
      id: account_status_likes_url(@account, @status),
      type: :unordered,
      size: @status.favourites_count
    )
  end
end
