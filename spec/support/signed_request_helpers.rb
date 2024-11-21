# frozen_string_literal: true

module SignedRequestHelpers
  def get(path, headers: nil, sign_with: nil, **args)
    return super(path, headers: headers, **args) if sign_with.nil?

    headers ||= {}
    headers['Date'] = Time.now.utc.httpdate
    headers['Host'] = Rails.configuration.x.local_domain
    signed_headers = headers.merge('(request-target)' => "get #{path}").slice('(request-target)', 'Host', 'Date')

    key_id = ActivityPub::TagManager.instance.key_uri_for(sign_with)
    keypair = sign_with.keypair
    signed_string = signed_headers.map { |key, value| "#{key.downcase}: #{value}" }.join("\n")
    signature = Base64.strict_encode64(keypair.sign(OpenSSL::Digest.new('SHA256'), signed_string))

    headers['Signature'] = "keyId=\"#{key_id}\",algorithm=\"rsa-sha256\",headers=\"#{signed_headers.keys.join(' ').downcase}\",signature=\"#{signature}\""

    super(path, headers: headers, **args)
  end
end
