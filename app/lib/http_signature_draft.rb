# frozen_string_literal: true

# This implements an older draft of HTTP Signatures:
# https://datatracker.ietf.org/doc/html/draft-cavage-http-signatures

class HttpSignatureDraft
  REQUEST_TARGET = '(request-target)'

  def initialize(keypair, key_id)
    @keypair = keypair
    @key_id = key_id
  end

  def request_target(verb, url)
    if url.query.nil?
      "#{verb} #{url.path}"
    else
      "#{verb} #{url.path}?#{url.query}"
    end
  end

  def sign(signed_headers, verb, url)
    signed_headers = signed_headers.merge(REQUEST_TARGET => request_target(verb, url))
    signed_string = signed_headers.map { |key, value| "#{key.downcase}: #{value}" }.join("\n")
    algorithm = 'rsa-sha256'
    signature = Base64.strict_encode64(@keypair.sign(OpenSSL::Digest.new('SHA256'), signed_string))

    "keyId=\"#{@key_id}\",algorithm=\"#{algorithm}\",headers=\"#{signed_headers.keys.join(' ').downcase}\",signature=\"#{signature}\""
  end
end
