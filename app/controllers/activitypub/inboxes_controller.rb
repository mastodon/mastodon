# frozen_string_literal: true

class ActivityPub::InboxesController < ActivityPub::BaseController
  include SignatureVerification
  include JsonLdHelper
  include AccountOwnedConcern

  before_action :skip_unknown_actor_delete
  before_action :require_signature!
  skip_before_action :authenticate_user!

  def create
    upgrade_account
    process_payload
    head 202
  end

  private

  def skip_unknown_actor_delete
    head 202 if unknown_deleted_account?
  end

  def unknown_deleted_account?
    json = Oj.load(body, mode: :strict)
    json.is_a?(Hash) && json['type'] == 'Delete' && json['actor'].present? && json['actor'] == value_or_id(json['object']) && !Account.where(uri: json['actor']).exists?
  rescue Oj::ParseError
    false
  end

  def account_required?
    params[:account_username].present?
  end

  def body
    return @body if defined?(@body)

    @body = request.body.read
    @body.force_encoding('UTF-8') if @body.present?

    request.body.rewind if request.body.respond_to?(:rewind)

    @body
  end

  def upgrade_account
    if signed_request_account.ostatus?
      signed_request_account.update(last_webfingered_at: nil)
      ResolveAccountWorker.perform_async(signed_request_account.acct)
    end

    DeliveryFailureTracker.reset!(signed_request_account.inbox_url)
  end

  def process_payload
    ActivityPub::ProcessingWorker.perform_async(signed_request_account.id, body, @account&.id)
  end
end
