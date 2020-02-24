# frozen_string_literal: true

class ActivityPub::InboxesController < Api::BaseController
  include SignatureVerification
  include JsonLdHelper

  before_action :set_account

  def create
    if unknown_deleted_account?
      head 202
    elsif signed_request_account
      upgrade_account
      process_payload
      head 202
    else
      render plain: signature_verification_failure_reason, status: 401
    end
  end

  private

  def unknown_deleted_account?
    json = Oj.load(body, mode: :strict)
    json['type'] == 'Delete' && json['actor'].present? && json['actor'] == value_or_id(json['object']) && !Account.where(uri: json['actor']).exists?
  rescue Oj::ParseError
    false
  end

  def set_account
    @account = Account.find_local!(params[:account_username]) if params[:account_username]
  end

  def body
    return @body if defined?(@body)
    @body = request.body.read.force_encoding('UTF-8')
    request.body.rewind if request.body.respond_to?(:rewind)
    @body
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
    ActivityPub::ProcessingWorker.perform_async(signed_request_account.id, body, @account&.id)
  end
end
