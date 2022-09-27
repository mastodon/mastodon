# frozen_string_literal: true

class ActivityPub::GroupInboxesController < ActivityPub::BaseController
  include SignatureVerification
  include JsonLdHelper
  include GroupOwnedConcern

  before_action :skip_unknown_actor_activity
  before_action :require_account_signature!
  skip_before_action :authenticate_user!

  def create
    upgrade_account
    process_payload
    head 202
  end

  private

  def skip_unknown_actor_activity
    head 202 if unknown_affected_account?
  end

  def unknown_affected_account?
    json = Oj.load(body, mode: :strict)
    json.is_a?(Hash) && %w(Delete Update).include?(json['type']) && json['actor'].present? && json['actor'] == value_or_id(json['object']) && !(Account.where(uri: json['actor']).exists? || Group.where(uri: json['actor']).exists?)
  rescue Oj::ParseError
    false
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
    if signed_request_account&.ostatus?
      signed_request_account.update(last_webfingered_at: nil)
      ResolveAccountWorker.perform_async(signed_request_account.acct)
    end

    DeliveryFailureTracker.reset!(signed_request_actor.inbox_url)
  end

  def process_payload
    ActivityPub::ProcessingWorker.perform_async(signed_request_actor.id, body, nil, signed_request_actor.class.name, @group.id)
  end
end
