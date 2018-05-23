require 'base64'

module Aws
  module S3
    module Encryption
      class Materials

        # @option options [required, OpenSSL::PKey::RSA, String] :key
        #   The master key to use for encrypting/decrypting all objects.
        #
        # @option options [String<JSON>] :description ('{}')
        #   The encryption materials description. This is must be
        #   a JSON document string.
        #
        def initialize(options = {})
          @key = validate_key(options[:key])
          @description = validate_desc(options[:description])
        end

        # @return [OpenSSL::PKey::RSA, String]
        attr_reader :key

        # @return [String<JSON>]
        attr_reader :description

        private

        def validate_key(key)
          case key
          when OpenSSL::PKey::RSA then key
          when String
            if [32, 24, 16].include?(key.bytesize)
              key
            else
              msg = "invalid key, symmetric key required to be 16, 24, or "
              msg << "32 bytes in length, saw length " + key.bytesize.to_s
              raise ArgumentError, msg
            end
          else
            msg = "invalid encryption key, expected an OpenSSL::PKey::RSA key "
            msg << "(for asymmetric encryption) or a String (for symmetric "
            msg << "encryption)."
            raise ArgumentError, msg
          end
        end

        def validate_desc(description)
          Json.load(description)
          description
        rescue Json::ParseError, EncodingError
          msg = "expected description to be a valid JSON document string"
          raise ArgumentError, msg
        end

      end
    end
  end
end
