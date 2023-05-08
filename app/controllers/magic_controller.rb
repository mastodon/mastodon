# frozen_string_literal: true

class MagicController < ApplicationController
  include WebAppControllerConcern

  before_action :authenticate_user!

  class Answer
    attr_accessor :success, :msg
  end

  def show
    # protect against mass assignment vulnerability
    params.permit(:owa, :bdest, :dest)

    expires_in 0, public: true unless user_signed_in?

    # get request parameters
    @dest = params.key?(:bdest) ? hex2bin(params[:bdest]) : params[:dest].to_s
    owa = params[:owa].to_s

    log("Magic - dest = #{@dest}")

    expires_in 0, public: true unless owa == '1'

    account = @current_account
    log("Current user:#{current_user.to_json}")

    data = { OpenWebAuth: random_string }.to_json

    # TODO: what if dest cannot be parsed => add 'rescue' block for URI::InvalidURIError ?
    parsed = URI.parse(@dest)
    host = parsed.host

    headers = {
      'Accept' => 'application/json',
      'Content-Type' => 'application/json',
      'X-Open-Web-Auth' => random_string,
      'Digest' => generate_digest_header(data),
      'Host' => host,
      '(request-target)' => 'post /owa',
    }
    owapath = URI("#{parsed.scheme}://#{host}#{parsed.port == 80 ? '' : ":#{parsed.port}"}/owa")
    log("Sending to #{owapath}")

    # I could not find a better way to get the user URL  (account.url is empty)
    # I found this way in the content_security_policy.rb initializer
    base_host = Rails.configuration.x.web_domain
    user_url = "#{host_to_url(base_host)}/@#{account.username}"
    log("User URL: #{user_url}")

    privkey = OpenSSL::PKey.read(account.private_key)
    signed_headers = generate_signed_headers(headers, privkey, user_url)
    log("Headers to send = #{signed_headers}")

    # returns Net::HTTPResponse object
    res = Net::HTTP.post(owapath, data, signed_headers)
    log("Status result: #{res.code}")
    redirect_fallthrough and return unless res.code == '200'

    body = JSON.parse(res.body)
    redirect_fallthrough and return unless body.key?('encrypted_token') && body.key?('success') && body['success'] != 'true'

    encrypted_token = body['encrypted_token']
    log('Success returned!')

    # decrypt encrypted token
    token = privkey.private_decrypt(Base64.urlsafe_decode64(encrypted_token))
    splitrest = @dest.partition('/[&?]/')
    args = splitrest[2].empty? ? "?f=&owt=#{token}" : "&owt=#{token}"

    redirectdest = @dest + args
    log("Redirecting to #{redirectdest} now")
    redirect_to redirectdest
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
    log("Signing with private key (#{pkey.p.num_bits} bits)")

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
    log('FAIL - Fallthrough!')
    redirect_to @dest
  end

  def log(msg)
    Rails.logger.info msg
  end
end
