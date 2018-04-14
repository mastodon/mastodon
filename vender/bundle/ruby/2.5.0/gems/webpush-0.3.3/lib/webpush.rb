require 'openssl'
require 'base64'
require 'hkdf'
require 'net/http'
require 'json'

require 'webpush/version'
require 'webpush/errors'
require 'webpush/vapid_key'
require 'webpush/encryption'
require 'webpush/request'

module Webpush
  class << self
    # Deliver the payload to the required endpoint given by the JavaScript
    # PushSubscription. Including an optional message requires p256dh and
    # auth keys from the PushSubscription.
    #
    # @param endpoint [String] the required PushSubscription url
    # @param message [String] the optional payload
    # @param p256dh [String] the user's public ECDH key given by the PushSubscription
    # @param auth [String] the user's private ECDH key given by the PushSubscription
    # @param vapid [Hash<Symbol,String>] options for VAPID
    # @option vapid [String] :subject contact URI for the app server as a "mailto:" or an "https:"
    # @option vapid [String] :public_key the VAPID public key
    # @option vapid [String] :private_key the VAPID private key
    # @param options [Hash<Symbol,String>] additional options for the notification
    # @option options [#to_s] :ttl Time-to-live in seconds
    def payload_send(message: "", endpoint:, p256dh: "", auth: "", vapid: {}, **options)
      subscription = {
        endpoint: endpoint,
        keys: {
          p256dh: p256dh,
          auth: auth
        }
      }
      Webpush::Request.new(
        message: message,
        subscription: subscription,
        vapid: vapid,
        **options
      ).perform
    end

    # Generate a VapidKey instance to obtain base64 encoded public and private keys
    # suitable for VAPID protocol JSON web token signing
    #
    # @return [Webpush::VapidKey] a new VapidKey instance
    def generate_key
      VapidKey.new
    end

    def encode64(bytes)
      Base64.urlsafe_encode64(bytes)
    end

    def decode64(str)
      # For Ruby < 2.3, Base64.urlsafe_decode64 strict decodes and will raise errors if encoded value is not properly padded
      # Implementation: http://ruby-doc.org/stdlib-2.3.0/libdoc/base64/rdoc/Base64.html#method-i-urlsafe_decode64
      if !str.end_with?("=") && str.length % 4 != 0
        str = str.ljust((str.length + 3) & ~3, "=")
      end

      Base64.urlsafe_decode64(str)
    end
  end
end
