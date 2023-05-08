# frozen_string_literal: true

#require 'json'
#require 'uri'
#require 'digest'
#require 'securerandom'

class MagicController < ApplicationController
  include WebAppControllerConcern

  before_action :authenticate_user!

  class Answer
    attr_accessor :success, :msg
  end

  def show
    # protect against mass assignment vulnerability
    params.permit(:owa, :bdest, :dest)

    log "Hit /magic endpoint"
    expires_in 0, public: true unless user_signed_in?
    log "user is logged in => OK"

    log("bdest = " + params[:bdest].to_s)

    # get request parameters
    @dest = params.has_key?(:bdest) ? hex2bin(params[:bdest]) : params[:dest].to_s
    owa = params[:owa].to_s

    log("dest = " + @dest)
    log("owa = " + owa)

    expires_in 0, public: true unless owa == "1"
    log("OWA detected!")

    account = @current_account
    # beware of this logging statement as it exposes the user's private key
    # log("Account: " + account.to_json)
    log("Current user:" + current_user.to_json)

    data = { :OpenWebAuth => random_string }.to_json
    log("Data = " + data.to_s)

    # TODO what if dest cannot be parsed => add 'rescue' block for URI::InvalidURIError ?
    parsed = URI.parse(@dest)
    host = parsed.host

    headers = {
      "Accept" => 'application/json',
      "Content-Type" => 'application/json',
      "X-Open-Web-Auth" => random_string,
      "Digest" => generate_digest_header(data),
      "Host" => host,
      "(request-target)" => 'post ' + '/owa',
    }
    log("Raw headers: " + headers.to_s)
    owapath = URI(parsed.scheme + '://' + host + (parsed.port != 80 ? ':' + parsed.port.to_s : '') + '/owa')
    log("Sending to " + owapath.to_s)
   
    # I could not find a better way to get the user URL  (account.url is empty)
    # I found this way in the content_security_policy.rb initializer
    base_host = Rails.configuration.x.web_domain
    userUrl = "#{host_to_url(base_host)}/@#{account.username}" 
    log("User URL: " + userUrl)

    headersToSign = headers.keys.map! {|h| h.downcase + ': ' + headers[h]}.join("\n")
    log('Headers to sign: ' + headersToSign)

    privkey = OpenSSL::PKey.read(account.private_key)
    # the strict_ is for avoiding newlines in base64 encoding
    signature = Base64.strict_encode64(sign(headersToSign, privkey, 'SHA512')) 
    log("Signature: " + signature)

    signedHeaders = {
      keyId: userUrl,
      algorithm: "rsa-sha512",
      headers: headers.keys.map! {|h| h.downcase }.join(" "),
      signature: signature
    }
    headerval = signedHeaders.keys.map! {|h| h.to_s + '=' + '"' + signedHeaders[h] + '"'}.join(",")
    log('Headerval = ' + headerval)
    headers = headers.except("(request-target)")
    headers.store("Authorization", "Signature " + headerval)
    log('Headers to send = ' + headers.to_s)

    # returns Net::HTTPResponse object
    res = Net::HTTP.post(owapath, data, headers)
    log ("Status result: " + res.code)
    redirect_fallthrough and return unless res.code == "200"
    body = JSON.parse(res.body)
    log ("Body: " + body.to_s)
    redirect_fallthrough and return unless body.has_key?("encrypted_token") && body.has_key?("success") && body["success"] != "true"
    encrypted_token = body["encrypted_token"]
    log ("Success returned! Encrypted token: " + encrypted_token)

    # decrypt encrypted token
    token = privkey.private_decrypt(Base64::urlsafe_decode64(encrypted_token))
    log("Decrypted token: " + token)
    splitrest = @dest.partition('/[&?]/')
    log("Dest splitting: " + splitrest.to_s)
    args = !splitrest[2].empty? ? '&owt=' + token : '?f=&owt=' + token

    redirectdest = @dest + args
    log("Redirecting to " + redirectdest + " now")
    redirect_to redirectdest 
  end

  private

#  https://stackoverflow.com/questions/5244414/shortest-hex2bin-in-ruby
  def hex2bin (arg)
    [arg].pack "H*"
  end

  def generate_digest_header (data)
    "SHA-256=" + Digest::SHA256.base64digest(data)
  end

  def random_string (size = 64)
    SecureRandom.hex(size)
  end

  def sign (message, pkey, alg = 'SHA256')
    log("Signing with private key (" + pkey.p.num_bits.to_s + " bits)")
  
    pkey.sign(alg, message)
  end

  def redirect_fallthrough
    log("FAIL - Fallthrough!")
    redirect_to @dest
  end

  def log (m)
    Rails.logger.info "TEST " + m
  end

end
