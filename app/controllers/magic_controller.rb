# frozen_string_literal: true

class MagicController < ApplicationController
  include WebAppControllerConcern

  before_action :authenticate_user!

  def show
    params.permit(:owa, :bdest, :dest)

    expires_in 0, public: true unless user_signed_in?

    @dest = params.key?(:bdest) ? hex2bin(params[:bdest]) : params[:dest].to_s
    owa = params[:owa].to_s

    log("Magic invoked - destination = #{@dest}")

    expires_in 0, public: true unless owa == '1'

    account = @current_account
    debug("Current user:#{current_user.to_json}")

    data = { OpenWebAuth: random_string }.to_json

    parsed = URI.parse(@dest)
    host = parsed.host
    port = parsed.port

    owapath = URI("#{parsed.scheme}://#{host}#{port == 80 ? '' : ":#{port}"}/owa")
    debug("Sending to #{owapath}")

    user_url = ActivityPub::TagManager.instance.key_uri_for(account)
    debug("User URL: #{user_url}")

    headers = {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'X-Open-Web-Auth' => random_string,
      'Digest' => generate_digest_header(data),
      'Host' => host,
      '(request-target)' => 'post /owa',
    }
    privkey = OpenSSL::PKey.read(account.private_key)
    signed_headers = generate_signed_headers(headers, privkey, user_url)
    debug("Headers to send = #{signed_headers}")

    # returns Net::HTTPResponse object
    res = Net::HTTP.post(owapath, data, signed_headers)
    debug("Response: #{res}")
    debug("Status result: #{res.code}")
    redirect_fallthrough and return unless res.is_a? Net::HTTPSuccess

    body = JSON.parse(res.body)
    debug("Response body: #{body}")
    redirect_fallthrough and return unless body.key?('encrypted_token') && body.key?('success') && body['success'] == true

    encrypted_token = body['encrypted_token']
    debug("Success returned! Encrypted token = #{encrypted_token}")

    # decrypt encrypted token
    token = privkey.private_decrypt(Base64.urlsafe_decode64(encrypted_token))
    splitrest = @dest.partition('/[&?]/')
    args = splitrest[2].empty? ? "?f=&owt=#{token}" : "&owt=#{token}"

    redirectdest = @dest + args
    log("Magic - Redirecting to #{redirectdest} now")
    redirect_to redirectdest
  rescue OpenSSL::PKey::RSAError => e
    log("Magic - RSA error: #{e.message}")
    redirect_fallthrough
  rescue URI::InvalidURIError
    log("Magic - Could not parse destination: #{@dest}")
    redirect_fallthrough
  end

  private

  #  https://stackoverflow.com/questions/5244414/shortest-hex2bin-in-ruby
  def hex2bin(arg)
    [arg].pack 'H*'
  end

  def generate_digest_header(data)
    "SHA-256=#{Digest::SHA256.base64digest(data)}"
  end

  def random_string(size = 64)
    SecureRandom.hex(size)
  end

  def sign(message, pkey, alg = 'SHA256')
    debug("Signing with private key (#{pkey.p.num_bits} bits)")

    pkey.sign(alg, message)
  end

  def generate_signed_headers(headers, private_key, user_url)
    headers_to_sign = headers.keys.map! { |h| "#{h.downcase}: #{headers[h]}" }.join("\n")

    # the strict_ is for avoiding newlines in base64 encoding
    signature = Base64.strict_encode64(sign(headers_to_sign, private_key, 'SHA512'))
    signed_headers = {
      keyId: user_url,
      algorithm: 'rsa-sha512',
      headers: headers.keys.map!(&:downcase).join(' '),
      signature: signature,
    }
    headerval = signed_headers.keys.map! { |h| "#{h}=\"#{signed_headers[h]}\"" }.join(',')
    headers.except('(request-target)').merge({ 'Authorization' => "Signature #{headerval}" })
  end

  def redirect_fallthrough
    log('Magic - FAIL: Fallthrough to destination')
    redirect_to @dest
  end

  def log(msg)
    Rails.logger.info msg
  end

  def debug(msg)
    Rails.logger.debug msg
  end
end
