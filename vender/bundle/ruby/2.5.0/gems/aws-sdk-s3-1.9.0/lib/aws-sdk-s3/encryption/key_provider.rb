module Aws
  module S3
    module Encryption

      # This module defines the interface required for a {Client#key_provider}.
      # A key provider is any object that:
      #
      # * Responds to {#encryption_materials} with an {Materials} object.
      #
      # * Responds to {#key_for}, receiving a JSON document String,
      #   returning an encryption key. The returned encryption key
      #   must be one of:
      #
      #   * `OpenSSL::PKey::RSA` - for asymmetric encryption
      #   * `String` - 32, 24, or 16 bytes long, for symmetric encryption
      #
      module KeyProvider

        # @return [Materials]
        def encryption_materials; end

        # @param [String<JSON>] materials_description
        # @return [OpenSSL::PKey::RSA, String] encryption_key
        def key_for(materials_description); end

      end
    end
  end
end
