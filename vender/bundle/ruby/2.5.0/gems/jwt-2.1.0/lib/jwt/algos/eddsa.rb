module JWT
  module Algos
    module Eddsa
      module_function

      SUPPORTED = %w[ED25519].freeze

      def sign(to_sign)
        algorithm, msg, key = to_sign.values
        raise EncodeError, "Key given is a #{key.class} but has to be an RbNaCl::Signatures::Ed25519::SigningKey" if key.class != RbNaCl::Signatures::Ed25519::SigningKey
        raise IncorrectAlgorithm, "payload algorithm is #{algorithm} but #{key.primitive} signing key was provided"  if algorithm.downcase.to_sym != key.primitive
        key.sign(msg)
      end

      def verify(to_verify)
        algorithm, public_key, signing_input, signature = to_verify.values
        raise IncorrectAlgorithm, "payload algorithm is #{algorithm} but #{public_key.primitive} verification key was provided" if algorithm.downcase.to_sym != public_key.primitive
        raise DecodeError, "key given is a #{public_key.class} but has to be a RbNaCl::Signatures::Ed25519::VerifyKey" if public_key.class != RbNaCl::Signatures::Ed25519::VerifyKey
        public_key.verify(signature, signing_input)
      end
    end
  end
end
