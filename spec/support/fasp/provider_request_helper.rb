# frozen_string_literal: true

module ProviderRequestHelper
  private

  def stub_provider_request(provider, path: '/', method: :get, response_status: 200, response_body: '')
    response_body = encode_body(response_body)
    response_headers = {
      'content-type' => 'application/json',
    }.merge(response_authentication_headers(provider, response_status, response_body))

    stub_request(method, provider.url(path))
      .to_return do |_request|
        {
          status: response_status,
          body: response_body,
          headers: response_headers,
        }
      end
  end

  def request_authentication_headers(provider, url: root_url, method: :get, body: '')
    body = encode_body(body)
    headers = {}
    headers['content-digest'] = content_digest(body)
    request = Linzer.new_request(method, url, {}, headers)
    key = private_key_for(provider)
    signature = sign(request, key, %w(@method @target-uri content-digest))
    headers.merge(signature.to_h)
  end

  def response_authentication_headers(provider, status, body)
    headers = {}
    headers['content-digest'] = content_digest(body)
    response = Linzer.new_response(body, status, headers)
    key = private_key_for(provider)
    signature = sign(response, key, %w(@status content-digest))
    headers.merge(signature.to_h)
  end

  def private_key_for(provider)
    @cached_provider_keys ||= {}
    @cached_provider_keys[provider] ||=
      begin
        key = OpenSSL::PKey.generate_key('ed25519')
        provider.update!(provider_public_key_pem: key.public_to_pem)
        key
      end

    {
      id: provider.id.to_s,
      private_key: @cached_provider_keys[provider].private_to_pem,
    }
  end

  def sign(request_or_response, key, components)
    message = Linzer::Message.new(request_or_response)
    linzer_key = Linzer.new_ed25519_key(key[:private_key], key[:id])
    Linzer.sign(linzer_key, message, components)
  end

  def encode_body(body)
    return body if body.nil? || body.is_a?(String)

    encoder = ActionDispatch::RequestEncoder.encoder(:json)
    encoder.encode_params(body)
  end

  def content_digest(content)
    "sha-256=:#{OpenSSL::Digest.base64digest('sha256', content)}:"
  end
end
