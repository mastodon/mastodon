# frozen_string_literal: true

class Api::Fasp::BaseController < ApplicationController
  class Error < ::StandardError; end

  DIGEST_PATTERN = /sha-256=:(.*?):/
  KEYID_PATTERN = /keyid="(.*?)"/

  attr_reader :current_provider

  skip_forgery_protection

  before_action :check_fasp_enabled
  before_action :require_authentication
  after_action :sign_response

  private

  def require_authentication
    validate_content_digest!
    validate_signature!
  rescue Error, Linzer::Error, ActiveRecord::RecordNotFound => e
    logger.debug("FASP Authentication error: #{e}")
    authentication_error
  end

  def authentication_error
    respond_to do |format|
      format.json { head 401 }
    end
  end

  def validate_content_digest!
    content_digest_header = request.headers['content-digest']
    raise Error, 'content-digest missing' if content_digest_header.blank?

    digest_received = content_digest_header.match(DIGEST_PATTERN)[1]

    digest_computed = OpenSSL::Digest.base64digest('sha256', request.body&.string || '')

    raise Error, 'content-digest does not match' if digest_received != digest_computed
  end

  def validate_signature!
    raise Error, 'signature-input is missing' if request.headers['signature-input'].blank?

    provider = nil

    Linzer.verify!(request.rack_request, no_older_than: 5.minutes) do |keyid|
      provider = Fasp::Provider.confirmed.find(keyid)
      Linzer.new_ed25519_public_key(provider.provider_public_key_pem, keyid)
    end

    @current_provider = provider
  end

  def sign_response
    response.headers['content-digest'] = "sha-256=:#{OpenSSL::Digest.base64digest('sha256', response.body || '')}:"
    key = Linzer.new_ed25519_key(current_provider.server_private_key_pem)
    Linzer.sign!(response, key:, components: %w(@status content-digest))
  end

  def check_fasp_enabled
    raise ActionController::RoutingError unless Mastodon::Feature.fasp_enabled?
  end
end
