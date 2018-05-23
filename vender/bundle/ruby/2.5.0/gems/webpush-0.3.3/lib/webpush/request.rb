require 'jwt'
require 'base64'

module Webpush
  # It is temporary URL until supported by the GCM server.
  GCM_URL = 'https://android.googleapis.com/gcm/send'
  TEMP_GCM_URL = 'https://gcm-http.googleapis.com/gcm'

  class Request
    def initialize(message: "", subscription:, vapid:, **options)
      endpoint = subscription.fetch(:endpoint)
      @endpoint = endpoint.gsub(GCM_URL, TEMP_GCM_URL)
      @payload = build_payload(message, subscription)
      @vapid_options = vapid
      @options = default_options.merge(options)
    end

    def perform
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = Net::HTTP::Post.new(uri.request_uri, headers)
      req.body = body
      resp = http.request(req)

      if resp.is_a?(Net::HTTPGone) ||   #Firefox unsubscribed response
          (resp.is_a?(Net::HTTPBadRequest) && resp.message == "UnauthorizedRegistration")  #Chrome unsubscribed response
        raise InvalidSubscription.new(resp, uri.host)
      elsif resp.is_a?(Net::HTTPNotFound) # 404
        raise ExpiredSubscription.new(resp, uri.host)
      elsif resp.is_a?(Net::HTTPRequestEntityTooLarge) # 413
        raise PayloadTooLarge.new(resp, uri.host)
      elsif resp.is_a?(Net::HTTPTooManyRequests) # 429, try again later!
        raise TooManyRequests.new(resp, uri.host)
      elsif !resp.is_a?(Net::HTTPSuccess)  # unknown/unhandled response error
        raise ResponseError.new(resp, uri.host)
      end

      resp
    end

    def headers
      headers = {}
      headers["Content-Type"] = "application/octet-stream"
      headers["Ttl"]          = ttl

      if @payload.has_key?(:server_public_key)
        headers["Content-Encoding"] = "aesgcm"
        headers["Encryption"] = "salt=#{salt_param}"
        headers["Crypto-Key"] = "dh=#{dh_param}"
      end

      if api_key?
        headers["Authorization"] = api_key
      elsif vapid?
        vapid_headers = build_vapid_headers
        headers["Authorization"] = vapid_headers["Authorization"]
        headers["Crypto-Key"] = [ headers["Crypto-Key"], vapid_headers["Crypto-Key"] ].compact.join(";")
      end

      headers
    end

    def build_vapid_headers
      vapid_key = VapidKey.from_keys(vapid_public_key, vapid_private_key)
      jwt = JWT.encode(jwt_payload, vapid_key.curve, 'ES256', jwt_header_fields)
      p256ecdsa = vapid_key.public_key_for_push_header

      {
        'Authorization' => 'WebPush ' + jwt,
        'Crypto-Key' => 'p256ecdsa=' + p256ecdsa,
      }
    end

    def body
      @payload.fetch(:ciphertext, "")
    end

    private

    def uri
      @uri ||= URI.parse(@endpoint)
    end

    def ttl
      @options.fetch(:ttl).to_s
    end

    def dh_param
      trim_encode64(@payload.fetch(:server_public_key))
    end

    def salt_param
      trim_encode64(@payload.fetch(:salt))
    end

    def jwt_payload
      {
        aud: audience,
        exp: Time.now.to_i + expiration,
        sub: subject,
      }
    end

    def jwt_header_fields
      { 'typ' => 'JWT' }
    end

    def audience
      uri.scheme + "://" + uri.host
    end

    def expiration
      @vapid_options.fetch(:expiration, 24*60*60)
    end

    def subject
      @vapid_options.fetch(:subject, 'sender@example.com')
    end

    def vapid_public_key
      @vapid_options.fetch(:public_key, nil)
    end

    def vapid_private_key
      @vapid_options.fetch(:private_key, nil)
    end

    def default_options
      {
        ttl: 60*60*24*7*4 # 4 weeks
      }
    end

    def build_payload(message, subscription)
      return {} if message.nil? || message.empty?

      encrypt_payload(message, subscription.fetch(:keys))
    end

    def encrypt_payload(message, p256dh:, auth:)
      Encryption.encrypt(message, p256dh, auth)
    end

    def api_key
      @options.fetch(:api_key, nil)
    end

    def api_key?
      !(api_key.nil? || api_key.empty?) && @endpoint =~ /\Ahttps:\/\/(android|gcm-http)\.googleapis\.com/
    end

    def vapid?
      @vapid_options.any?
    end

    def trim_encode64(bin)
      Webpush.encode64(bin).delete('=')
    end
  end
end
