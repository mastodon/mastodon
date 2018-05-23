module JWT
  module Algos
    module Ecdsa
      module_function

      SUPPORTED = %(ES256 ES384 ES512).freeze
      NAMED_CURVES = {
        'prime256v1' => 'ES256',
        'secp384r1' => 'ES384',
        'secp521r1' => 'ES512'
      }.freeze

      def sign(to_sign)
        algorithm, msg, key = to_sign.values
        key_algorithm = NAMED_CURVES[key.group.curve_name]
        if algorithm != key_algorithm
          raise IncorrectAlgorithm, "payload algorithm is #{algorithm} but #{key_algorithm} signing key was provided"
        end

        digest = OpenSSL::Digest.new(algorithm.sub('ES', 'sha'))
        SecurityUtils.asn1_to_raw(key.dsa_sign_asn1(digest.digest(msg)), key)
      end

      def verify(to_verify)
        algorithm, public_key, signing_input, signature = to_verify.values
        key_algorithm = NAMED_CURVES[public_key.group.curve_name]
        if algorithm != key_algorithm
          raise IncorrectAlgorithm, "payload algorithm is #{algorithm} but #{key_algorithm} verification key was provided"
        end
        digest = OpenSSL::Digest.new(algorithm.sub('ES', 'sha'))
        public_key.dsa_verify_asn1(digest.digest(signing_input), SecurityUtils.raw_to_asn1(signature, public_key))
      end
    end
  end
end
