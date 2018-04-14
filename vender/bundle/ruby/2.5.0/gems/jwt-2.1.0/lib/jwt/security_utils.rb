module JWT
  # Collection of security methods
  #
  # @see: https://github.com/rails/rails/blob/master/activesupport/lib/active_support/security_utils.rb
  module SecurityUtils
    module_function

    def secure_compare(left, right)
      left_bytesize = left.bytesize

      return false unless left_bytesize == right.bytesize

      unpacked_left = left.unpack "C#{left_bytesize}"
      result = 0
      right.each_byte { |byte| result |= byte ^ unpacked_left.shift }
      result.zero?
    end

    def verify_rsa(algorithm, public_key, signing_input, signature)
      public_key.verify(OpenSSL::Digest.new(algorithm.sub('RS', 'sha')), signature, signing_input)
    end

    def asn1_to_raw(signature, public_key)
      byte_size = (public_key.group.degree + 7) / 8
      OpenSSL::ASN1.decode(signature).value.map { |value| value.value.to_s(2).rjust(byte_size, "\x00") }.join
    end

    def raw_to_asn1(signature, private_key)
      byte_size = (private_key.group.degree + 7) / 8
      sig_bytes = signature[0..(byte_size - 1)]
      sig_char = signature[byte_size..-1] || ''
      OpenSSL::ASN1::Sequence.new([sig_bytes, sig_char].map { |int| OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(int, 2)) }).to_der
    end

    def rbnacl_fixup(algorithm, key)
      algorithm = algorithm.sub('HS', 'SHA').to_sym

      return [] unless defined?(RbNaCl) && RbNaCl::HMAC.constants(false).include?(algorithm)

      authenticator = RbNaCl::HMAC.const_get(algorithm)

      # Fall back to OpenSSL for keys larger than 32 bytes.
      return [] if key.bytesize > authenticator.key_bytes

      [
        authenticator,
        key.bytes.fill(0, key.bytesize...authenticator.key_bytes).pack('C*')
      ]
    end
  end
end
