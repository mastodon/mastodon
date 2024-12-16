# frozen_string_literal: true

class Fasp::Request
  def initialize(provider)
    @provider = provider
  end

  def get(path)
    url = @provider.url(path)
    response = HTTP.headers(headers('GET', url)).get(url)
    validate!(response)

    response.parse
  end

  def post(path, body: nil)
    url = @provider.url(path)
    body = body.to_json
    response = HTTP.headers(headers('POST', url, body)).post(url, body:)

    response.parse if response.body.present?
  end

  private

  def headers(verb, url, body = '')
    result = {
      'accept' => 'application/json',
      'content-type' => 'application/json',
      'content-digest' => content_digest(body),
    }
    result.merge(signature_headers(verb, url, result))
  end

  def content_digest(body)
    "sha-256=:#{OpenSSL::Digest.base64digest('sha256', body || '')}:"
  end

  def signature_headers(verb, url, headers)
    linzer_request = Linzer.new_request(verb, url, {}, headers)
    message = Linzer::Message.new(linzer_request)
    key = Linzer.new_ed25519_key(@provider.server_private_key.raw_private_key, @provider.remote_identifier)
    signature = Linzer.sign(key, message, %w(@method @target-uri content-digest))
    Linzer::Signer.send(:populate_parameters, key, {})

    signature.to_h
  end

  def validate!(response)
    content_digest_header = response.headers['content-digest']
    raise 'content-digest missing' if content_digest_header.blank?
    raise 'content-digest does not match' if content_digest_header != content_digest(response.body)

    signature_input = response.headers['signature-input'].encode('UTF-8')
    raise 'signature-input is missing' if signature_input.blank?

    linzer_response = Linzer.new_response(
      response.body,
      response.status,
      {
        'content-digest' => content_digest_header,
        'signature-input' => signature_input,
        'signature' => response.headers['signature'],
      }
    )
    message = Linzer::Message.new(linzer_response)
    key = Linzer.new_ed25519_public_key(@provider.provider_public_key_raw)
    signature = Linzer::Signature.build(message.headers)
    Linzer.verify(key, message, signature)
  end
end
