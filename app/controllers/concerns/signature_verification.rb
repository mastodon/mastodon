# frozen_string_literal: true

# Implemented according to HTTP signatures (Draft 6)
# <https://tools.ietf.org/html/draft-cavage-http-signatures-06>
module SignatureVerification
  extend ActiveSupport::Concern

  def signed_request?
    request.headers['Signature'].present?
  end

  def signature_verification_failure_reason
    return @signature_verification_failure_reason if defined?(@signature_verification_failure_reason)
  end

  def signed_request_account
    return @signed_request_account if defined?(@signed_request_account)

    unless signed_request?
      @signature_verification_failure_reason = 'Request not signed'
      @signed_request_account = nil
      return
    end

    if request.headers['Date'].present? && !matches_time_window?
      @signature_verification_failure_reason = 'Signed request date outside acceptable time window'
      @signed_request_account = nil
      return
    end

    raw_signature    = request.headers['Signature']
    signature_params = {}

    raw_signature.split(',').each do |part|
      parsed_parts = part.match(/([a-z]+)="([^"]+)"/i)
      next if parsed_parts.nil? || parsed_parts.size != 3
      signature_params[parsed_parts[1]] = parsed_parts[2]
    end

    if incompatible_signature?(signature_params)
      @signature_verification_failure_reason = 'Incompatible request signature'
      @signed_request_account = nil
      return
    end

    account = account_from_key_id(signature_params['keyId'])

    if account.nil?
      @signature_verification_failure_reason = "Public key not found for key #{signature_params['keyId']}"
      @signed_request_account = nil
      return
    end

    signature             = Base64.decode64(signature_params['signature'])
    compare_signed_string = build_signed_string(signature_params['headers'])

    if account.keypair.public_key.verify(OpenSSL::Digest::SHA256.new, signature, compare_signed_string)
      @signed_request_account = account
      @signed_request_account
    elsif account.possibly_stale?
      account = account.refresh!

      if account.keypair.public_key.verify(OpenSSL::Digest::SHA256.new, signature, compare_signed_string)
        @signed_request_account = account
        @signed_request_account
      else
        @signature_verification_failure_reason = "Verification failed for #{account.username}@#{account.domain} #{account.uri}"
        @signed_request_account = nil
      end
    else
      @signature_verification_failure_reason = "Verification failed for #{account.username}@#{account.domain} #{account.uri}"
      @signed_request_account = nil
    end
  end

  def request_body
    @request_body ||= request.raw_post
  end

  private

  def build_signed_string(signed_headers)
    signed_headers = 'date' if signed_headers.blank?

    signed_headers.downcase.split(' ').map do |signed_header|
      if signed_header == Request::REQUEST_TARGET
        "#{Request::REQUEST_TARGET}: #{request.method.downcase} #{request.path}"
      elsif signed_header == 'digest'
        "digest: #{body_digest}"
      else
        "#{signed_header}: #{request.headers[to_header_name(signed_header)]}"
      end
    end.join("\n")
  end

  def matches_time_window?
    begin
      time_sent = Time.httpdate(request.headers['Date'])
    rescue ArgumentError
      return false
    end

    (Time.now.utc - time_sent).abs <= 12.hours
  end

  def body_digest
    "SHA-256=#{Digest::SHA256.base64digest(request_body)}"
  end

  def to_header_name(name)
    name.split(/-/).map(&:capitalize).join('-')
  end

  def incompatible_signature?(signature_params)
    signature_params['keyId'].blank? ||
      signature_params['signature'].blank?
  end

  def account_from_key_id(key_id)
    if key_id.start_with?('acct:')
      ResolveAccountService.new.call(key_id.gsub(/\Aacct:/, ''))
    elsif !ActivityPub::TagManager.instance.local_uri?(key_id)
      account   = ActivityPub::TagManager.instance.uri_to_resource(key_id, Account)
      account ||= ActivityPub::FetchRemoteKeyService.new.call(key_id, id: false)
      account
    end
  end
end
