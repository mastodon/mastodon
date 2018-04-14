module OStatus2
  module MagicKey
    if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.4.0')
      def set_key(key, modulus, exponent)
        key.n = modulus
        key.e = exponent
      end
    else
      def set_key(key, modulus, exponent)
        key.set_key(modulus, exponent, nil)
      end
    end

    def magic_key_to_pem(magic_key)
      _, modulus, exponent = magic_key.split('.')
      modulus, exponent = [modulus, exponent].map { |n| decode_base64(n).bytes.inject(0) { |a, e| (a << 8) | e } }

      key = OpenSSL::PKey::RSA.new
      set_key(key, modulus, exponent)
      key.to_pem
    end

    def decode_base64(string)
      retries = 0

      begin
        return Base64::urlsafe_decode64(string)
      rescue ArgumentError
        retries += 1
        string = "#{string}="
        retry unless retries > 2
      end
    end
  end
end
