# frozen_string_literal: true

# Implemented according to HTTP signatures (Draft 6)
# <https://tools.ietf.org/html/draft-cavage-http-signatures-06>
module SignatureVerification
  extend ActiveSupport::Concern

  include DomainControlHelper

  EXPIRATION_WINDOW_LIMIT = 12.hours
  CLOCK_SKEW_MARGIN       = 1.hour
  STOPLIGHT_COOL_OFF_TIME = 5.minutes.seconds
  STOPLIGHT_THRESHOLD = 1

  def require_account_signature!
    render json: signature_verification_failure_reason, status: signature_verification_failure_code unless signed_request_account
  end

  def require_actor_signature!
    render json: signature_verification_failure_reason, status: signature_verification_failure_code unless signed_request_actor
  end

  def signed_request?
    request.headers['Signature'].present?
  end

  def signature_key_id
    signed_request.key_id
  rescue Mastodon::SignatureVerificationError
    nil
  end

  private

  def signed_request
    @signed_request ||= SignedRequest.new(request) if signed_request?
  end

  def signature_verification_failure_reason
    @signature_verification_failure_reason
  end

  def signature_verification_failure_code
    @signature_verification_failure_code || 401
  end

  def signed_request_account
    signed_request_actor.is_a?(Account) ? signed_request_actor : nil
  end

  def signed_request_actor
    return @signed_request_actor if defined?(@signed_request_actor)

    raise Mastodon::SignatureVerificationError, 'Request not signed' unless signed_request?

    actor = actor_from_key_id

    raise Mastodon::SignatureVerificationError, "Public key not found for key #{signature_key_id}" if actor.nil?

    return (@signed_request_actor = actor) if signed_request.verified?(actor)

    actor = stoplight_wrapper.run { actor_refresh_key!(actor) }

    raise Mastodon::SignatureVerificationError, "Could not refresh public key #{signature_key_id}" if actor.nil?

    return (@signed_request_actor = actor) if signed_request.verified?(actor)

    fail_with! "Verification failed for #{actor.to_log_human_identifier} #{actor.uri}"
  rescue Mastodon::MalformedHeaderError => e
    @signature_verification_failure_code = 400
    fail_with! e.message
  rescue Mastodon::SignatureVerificationError => e
    fail_with! e.message
  rescue *Mastodon::HTTP_CONNECTION_ERRORS => e
    @signature_verification_failure_code ||= 503
    fail_with! "Failed to fetch remote data: #{e.message}"
  rescue Mastodon::UnexpectedResponseError
    @signature_verification_failure_code ||= 503
    fail_with! 'Failed to fetch remote data (got unexpected reply from server)'
  rescue Stoplight::Error::RedLight
    @signature_verification_failure_code ||= 503
    fail_with! 'Fetching attempt skipped because of recent connection failure'
  end

  def fail_with!(message, **options)
    Rails.logger.debug { "Signature verification failed: #{message}" }

    @signature_verification_failure_reason = { error: message }.merge(options)
    @signed_request_actor = nil
  end

  def actor_from_key_id
    key_id = signed_request.key_id
    domain = key_id.start_with?('acct:') ? key_id.split('@').last : key_id

    if domain_not_allowed?(domain)
      @signature_verification_failure_code = 403
      return
    end

    if key_id.start_with?('acct:')
      stoplight_wrapper.run { ResolveAccountService.new.call(key_id.delete_prefix('acct:'), suppress_errors: false) }
    elsif !ActivityPub::TagManager.instance.local_uri?(key_id)
      account   = ActivityPub::TagManager.instance.uri_to_actor(key_id)
      account ||= stoplight_wrapper.run { ActivityPub::FetchRemoteKeyService.new.call(key_id, suppress_errors: false) }
      account
    end
  rescue Mastodon::PrivateNetworkAddressError => e
    raise Mastodon::SignatureVerificationError, "Requests to private network addresses are disallowed (tried to query #{e.host})"
  rescue Mastodon::HostValidationError, ActivityPub::FetchRemoteActorService::Error, ActivityPub::FetchRemoteKeyService::Error, Webfinger::Error => e
    raise Mastodon::SignatureVerificationError, e.message
  end

  def stoplight_wrapper
    Stoplight(
      "source:#{request.remote_ip}",
      cool_off_time: STOPLIGHT_COOL_OFF_TIME,
      threshold: STOPLIGHT_THRESHOLD,
      tracked_errors: [HTTP::Error, OpenSSL::SSL::SSLError]
    )
  end

  def actor_refresh_key!(actor)
    return if actor.local? || !actor.activitypub?
    return actor.refresh! if actor.respond_to?(:refresh!) && actor.possibly_stale?

    ActivityPub::FetchRemoteActorService.new.call(actor.uri, only_key: true, suppress_errors: false)
  rescue Mastodon::PrivateNetworkAddressError => e
    raise Mastodon::SignatureVerificationError, "Requests to private network addresses are disallowed (tried to query #{e.host})"
  rescue Mastodon::HostValidationError, ActivityPub::FetchRemoteActorService::Error, Webfinger::Error => e
    raise Mastodon::SignatureVerificationError, e.message
  end
end
