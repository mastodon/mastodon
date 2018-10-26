# frozen_string_literal: true

class ActivityPub::InboxesController < Api::BaseController
  include SignatureVerification

  before_action :set_account

  def create
    if signed_request_account
      upgrade_account
      process_payload
      head 202
    else
      render plain: signature_verification_failure_reason, status: 401
    end
  end

  private

  def set_account
    @account = Account.find_local!(params[:account_username]) if params[:account_username]
  end

  def body
    @body ||= request.body.read
  end

  def upgrade_account
    if signed_request_account.ostatus?
      signed_request_account.update(last_webfingered_at: nil)
      ResolveAccountWorker.perform_async(signed_request_account.acct)
    end

    Pubsubhubbub::UnsubscribeWorker.perform_async(signed_request_account.id) if signed_request_account.subscribed?
    DeliveryFailureTracker.track_inverse_success!(signed_request_account)
  end

  def process_payload
    ActivityPub::ProcessingWorker.perform_async(signed_request_account.id, body.force_encoding('UTF-8'), @account&.id)
  end
end
