module Webpush
  # Class for abstracting the generation and encoding of elliptic curve public and private keys for use with the VAPID protocol
  #
  # @attr_reader [OpenSSL::PKey::EC] :curve the OpenSSL elliptic curve instance
  class VapidKey
    # Create a VapidKey instance from encoded elliptic curve public and private keys
    #
    # @return [Webpush::VapidKey] a VapidKey instance for the given public and private keys
    def self.from_keys(public_key, private_key)
      key = new
      key.public_key = public_key
      key.private_key = private_key

      key
    end

    attr_reader :curve

    def initialize
      @curve = OpenSSL::PKey::EC.new('prime256v1')
      @curve.generate_key
    end

    # Retrieve the encoded elliptic curve public key for VAPID protocol
    #
    # @return [String] encoded binary representation of 65-byte VAPID public key
    def public_key
      encode64(curve.public_key.to_bn.to_s(2))
    end

    # Retrieve the encoded elliptic curve public key suitable for the Web Push request
    #
    # @return [String] the encoded VAPID public key for us in 'Encryption' header
    def public_key_for_push_header
      trim_encode64(curve.public_key.to_bn.to_s(2))
    end

    # Retrive the encoded elliptic curve private key for VAPID protocol
    #
    # @return [String] base64 urlsafe-encoded binary representation of 32-byte VAPID private key
    def private_key
      encode64(curve.private_key.to_s(2))
    end

    def public_key=(key)
      curve.public_key = OpenSSL::PKey::EC::Point.new(group, to_big_num(key))
    end

    def private_key=(key)
      curve.private_key = to_big_num(key)
    end

    def curve_name
      group.curve_name
    end

    def group
      curve.group
    end

    def to_h
      { public_key: public_key, private_key: private_key }
    end
    alias to_hash to_h

    def inspect
      "#<#{self.class}:#{object_id.to_s(16)} #{to_h.map { |k, v| ":#{k}=#{v}" }.join(" ")}>"
    end

    private

    def to_big_num(key)
      OpenSSL::BN.new(Webpush.decode64(key), 2)
    end

    def encode64(bin)
      Webpush.encode64(bin)
    end

    def trim_encode64(bin)
      encode64(bin).delete('=')
    end
  end
end
