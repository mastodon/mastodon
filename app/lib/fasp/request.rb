# frozen_string_literal: true

class Fasp::Request
  COVERED_COMPONENTS = %w(@method @target-uri content-digest).freeze

  def initialize(provider)
    @provider = provider
  end

  def get(path)
    perform_request(:get, path)
  end

  def post(path, body: nil)
    perform_request(:post, path, body:)
  end

  def delete(path, body: nil)
    perform_request(:delete, path, body:)
  end

  private

  def perform_request(verb, path, body: nil)
    url = @provider.url(path)
    body = body.present? ? body.to_json : ''
    headers = request_headers(verb, url, body)
    key = Linzer.new_ed25519_key(@provider.server_private_key_pem, @provider.remote_identifier)
    response = HTTP
      .headers(headers)
      .use(http_signature: { key:, covered_components: COVERED_COMPONENTS })
      .send(verb, url, body:, socket_class: ::Request::Socket)

    validate!(response)
    @provider.delivery_failure_tracker.track_success!

    response.parse if response.body.present?
  rescue *::Mastodon::HTTP_CONNECTION_ERRORS
    @provider.delivery_failure_tracker.track_failure!
    raise
  end

  def request_headers(_verb, _url, body = '')
    {
      'accept' => 'application/json',
      'content-type' => 'application/json',
      'content-digest' => content_digest(body),
    }
  end

  def content_digest(body)
    "sha-256=:#{OpenSSL::Digest.base64digest('sha256', body || '')}:"
  end

  def validate!(response)
    raise Mastodon::UnexpectedResponseError, response if response.code >= 400

    content_digest_header = response.headers['content-digest']
    raise Mastodon::SignatureVerificationError, 'content-digest missing' if content_digest_header.blank?
    raise Mastodon::SignatureVerificationError, 'content-digest does not match' if content_digest_header != content_digest(response.body)
    raise Mastodon::SignatureVerificationError, 'signature-input is missing' if response.headers['signature-input'].blank?

    key = Linzer.new_ed25519_public_key(@provider.provider_public_key_pem)
    Linzer.verify!(response, key:)
  end
end
