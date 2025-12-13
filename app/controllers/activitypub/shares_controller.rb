# frozen_string_literal: true

class ActivityPub::SharesController < ActivityPub::BaseController
  include Authorization

  vary_by -> { 'Signature' if authorized_fetch_mode? }

  before_action :require_account_signature!, if: :authorized_fetch_mode?
  before_action :set_status

  def index
    expires_in 0, public: @status.distributable? && public_fetch_mode?
    render json: shares_collection_presenter, serializer: ActivityPub::CollectionSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
  end

  private

  def pundit_user
    signed_request_account
  end

  def set_status
    @status = @account.statuses.find(params[:status_id])
    authorize @status, :show?
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    not_found
  end

  def shares_collection_presenter
    ActivityPub::CollectionPresenter.new(
      id: ActivityPub::TagManager.instance.shares_uri_for(@status),
      type: :unordered,
      size: @status.reblogs_count
    )
  end
end
