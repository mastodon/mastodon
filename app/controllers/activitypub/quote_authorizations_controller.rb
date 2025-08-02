# frozen_string_literal: true

class ActivityPub::QuoteAuthorizationsController < ActivityPub::BaseController
  include Authorization

  vary_by -> { 'Signature' if authorized_fetch_mode? }

  before_action :require_account_signature!, if: :authorized_fetch_mode?
  before_action :set_quote_authorization

  def show
    expires_in 0, public: @quote.status.distributable? && public_fetch_mode?
    render json: @quote, serializer: ActivityPub::QuoteAuthorizationSerializer, adapter: ActivityPub::Adapter, content_type: 'application/activity+json'
  end

  private

  def pundit_user
    signed_request_account
  end

  def set_quote_authorization
    @quote = Quote.accepted.where(quoted_account: @account).find(params[:id])
    authorize @quote.status, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end
end
