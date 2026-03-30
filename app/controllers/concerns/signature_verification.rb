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

    keypair = keypair_from_key_id

    raise Mastodon::SignatureVerificationError, "Public key not found for key #{signature_key_id}" if keypair.nil?

    check_keypair_validity!(keypair)
    return (@signed_request_actor = keypair.actor) if signed_request.verified?(keypair)

    keypair = stoplight_wrapper.run { keypair_refresh_key!(keypair) }

    raise Mastodon::SignatureVerificationError, "Could not refresh public key #{signature_key_id}" if keypair.nil?

    check_keypair_validity!(keypair)
    return (@signed_request_actor = keypair.actor) if signed_request.verified?(keypair)

    fail_with! "Verification failed for #{keypair.actor.to_log_human_identifier} #{keypair.actor.uri} #{keypair.uri}"
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

  def keypair_from_key_id
    key_id = signed_request.key_id
    domain = key_id.start_with?('acct:') ? key_id.split('@').last : key_id

    if domain_not_allowed?(domain)
      @signature_verification_failure_code = 403
      return
    end

    if key_id.start_with?('acct:')
      stoplight_wrapper.run { ResolveAccountService.new.call(key_id.delete_prefix('acct:'), suppress_errors: false) }
    elsif !ActivityPub::TagManager.instance.local_uri?(key_id)
      keypair = Keypair.from_keyid(key_id)
      return keypair if keypair.present?

      stoplight_wrapper.run { ActivityPub::FetchRemoteKeyService.new.call(key_id, suppress_errors: false) }
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

  def keypair_refresh_key!(keypair)
    # TODO: this currently only is concerned with refreshing the actor and returning the legacy key, this needs to be reworked
    return if keypair.actor.local? || !keypair.actor.activitypub?
    return keypair.actor.refresh! if keypair.actor.respond_to?(:refresh!) && keypair.actor.possibly_stale?

    Keypair.from_legacy_account(ActivityPub::FetchRemoteActorService.new.call(keypair.actor.uri, only_key: true, suppress_errors: false))
  rescue Mastodon::PrivateNetworkAddressError => e
    raise Mastodon::SignatureVerificationError, "Requests to private network addresses are disallowed (tried to query #{e.host})"
  rescue Mastodon::HostValidationError, ActivityPub::FetchRemoteActorService::Error, Webfinger::Error => e
    raise Mastodon::SignatureVerificationError, e.message
  end

  def check_keypair_validity!(keypair)
    raise Mastodon::SignatureVerification, "Key #{signature_key_id} is revoked" if keypair.revoked?
    raise Mastodon::SignatureVerification, "Key #{signature_key_id} has expired" if keypair.expired?
  end
end
