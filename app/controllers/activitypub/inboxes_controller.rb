# frozen_string_literal: true

class ActivityPub::InboxesController < ActivityPub::BaseController
  include SignatureVerification
  include JsonLdHelper
  include AccountOwnedConcern

  before_action :skip_unknown_actor_activity!
  before_action :require_signature!
  skip_before_action :authenticate_user!

  ACCEPTED_HEADERS = %w(
    Collection-Synchronization
  ).freeze

  def create
    upgrade_account
    process_payload
    head(:accepted)
  end

  private

  def skip_unknown_actor_activity!
    head(:accepted) if unknown_affected_account?
  end

  def unknown_affected_account?
    json = Oj.load(body, mode: :strict)
    json.is_a?(Hash) && %w(Delete Update).include?(json['type']) && json['actor'].present? && json['actor'] == value_or_id(json['object']) && !Account.where(uri: json['actor']).exists?
  rescue Oj::ParseError
    false
  end

  def account_required?
    params[:account_username].present?
  end

  def skip_temporary_suspension_response?
    true
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
    ActivityPub::ProcessingWorker.perform_async(
      signed_request_account.id,
      body,
      @account&.id,
      accepted_headers_from_request
    )
  end

  def accepted_headers_from_request
    ACCEPTED_HEADERS.map { |header_name| [header_name, request.headers[header_name]] if request.headers[header_name].present? }.compact.to_h
  end
end
