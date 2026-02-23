# frozen_string_literal: true

module SignedRequestHelpers
  def get(path, headers: nil, sign_with: nil, **args)
    return super(path, headers: headers, **args) if sign_with.nil?

    headers ||= {}
    headers['Date'] = Time.now.utc.httpdate
    headers['Host'] = Rails.configuration.x.local_domain
    signed_headers = headers.merge('(request-target)' => "get #{path}").slice('(request-target)', 'Host', 'Date')

    keypair = sign_with.keypair
    key_id = keypair.uri
    signed_string = signed_headers.map { |key, value| "#{key.downcase}: #{value}" }.join("\n")
    signature = Base64.strict_encode64(keypair.keypair.sign(OpenSSL::Digest.new('SHA256'), signed_string))

    headers['Signature'] = "keyId=\"#{key_id}\",algorithm=\"rsa-sha256\",headers=\"#{signed_headers.keys.join(' ').downcase}\",signature=\"#{signature}\""

    super(path, headers: headers, **args)
  end

  def post(path, headers: nil, sign_with: nil, **args)
    return super(path, headers: headers, **args) if sign_with.nil?

    headers ||= {}
    headers['Date'] = Time.now.utc.httpdate
    headers['Host'] = Rails.configuration.x.local_domain
    headers['Digest'] = "SHA-256=#{Digest::SHA256.base64digest(args[:params].to_s)}"

    signed_headers = headers.merge('(request-target)' => "post #{path}").slice('(request-target)', 'Host', 'Date', 'Digest')

    keypair = sign_with.keypair
    key_id = keypair.uri
    signed_string = signed_headers.map { |key, value| "#{key.downcase}: #{value}" }.join("\n")
    signature = Base64.strict_encode64(keypair.keypair.sign(OpenSSL::Digest.new('SHA256'), signed_string))

    headers['Signature'] = "keyId=\"#{key_id}\",algorithm=\"rsa-sha256\",headers=\"#{signed_headers.keys.join(' ').downcase}\",signature=\"#{signature}\""

    super(path, headers: headers, **args)
  end
end
