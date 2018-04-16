module JWT
  module Algos
    module Rsa
      module_function

      SUPPORTED = %w[RS256 RS384 RS512].freeze

      def sign(to_sign)
        algorithm, msg, key = to_sign.values
        raise EncodeError, "The given key is a #{key.class}. It has to be an OpenSSL::PKey::RSA instance." if key.class == String
        key.sign(OpenSSL::Digest.new(algorithm.sub('RS', 'sha')), msg)
      end

      def verify(to_verify)
        SecurityUtils.verify_rsa(to_verify.algorithm, to_verify.public_key, to_verify.signing_input, to_verify.signature)
      end
    end
  end
end
