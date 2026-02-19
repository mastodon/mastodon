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
    request = "Net::HTTP::#{method.to_s.classify}".constantize.new(URI(url), headers)
    key = private_key_for(provider)
    Linzer.sign!(request, key:, components: %w(@method @target-uri content-digest))
    signature_headers(request)
  end

  def response_authentication_headers(provider, status, body)
    response = Net::HTTPResponse::CODE_TO_OBJ[status.to_s].new('1.1', status, Rack::Utils::HTTP_STATUS_CODES[status])
    response.body = body
    response['content-digest'] = content_digest(body)
    key = private_key_for(provider)
    Linzer.sign!(response, key:, components: %w(@status content-digest))
    signature_headers(response)
  end

  def signature_headers(operation)
    {
      'content-digest' => operation['content-digest'],
      'signature-input' => operation['signature-input'],
      'signature' => operation['signature'],
    }
  end

  def private_key_for(provider)
    @cached_provider_keys ||= {}
    @cached_provider_keys[provider] ||=
      begin
        key = OpenSSL::PKey.generate_key('ed25519')
        provider.update!(provider_public_key_pem: key.public_to_pem)
        key
      end

    Linzer.new_ed25519_key(@cached_provider_keys[provider].private_to_pem, provider.id.to_s)
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
