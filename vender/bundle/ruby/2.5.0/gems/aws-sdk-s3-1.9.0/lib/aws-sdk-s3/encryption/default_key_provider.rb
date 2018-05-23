module Aws
  module S3
    module Encryption

      # The default key provider is constructed with a single key
      # that is used for both encryption and decryption, ignoring
      # the possible per-object envelope encryption materials description.
      # @api private
      class DefaultKeyProvider

        include KeyProvider

        # @option options [required, OpenSSL::PKey::RSA, String] :encryption_key
        #   The master key to use for encrypting objects.
        # @option options [String<JSON>] :materials_description ('{}')
        #   A description of the encryption key.
        def initialize(options = {})
          @encryption_materials = Materials.new(
            key: options[:encryption_key],
            description: options[:materials_description] || '{}'
          )
        end

        # @return [Materials]
        def encryption_materials
          @encryption_materials
        end

        # @param [String<JSON>] materials_description
        # @return Returns the key given in the constructor.
        def key_for(materials_description)
          @encryption_materials.key
        end

      end
    end
  end
end
