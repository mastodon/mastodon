# frozen_string_literal: true

module HTTP
  # MIME type encode/decode adapters
  module MimeType
    class << self
      # Associate MIME type with adapter
      #
      # @example
      #
      #   module JsonAdapter
      #     class << self
      #       def encode(obj)
      #         # encode logic here
      #       end
      #
      #       def decode(str)
      #         # decode logic here
      #       end
      #     end
      #   end
      #
      #   HTTP::MimeType.register_adapter 'application/json', MyJsonAdapter
      #
      # @param [#to_s] type
      # @param [#encode, #decode] adapter
      # @return [void]
      def register_adapter(type, adapter)
        adapters[type.to_s] = adapter
      end

      # Returns adapter associated with MIME type
      #
      # @param [#to_s] type
      # @raise [Error] if no adapter found
      # @return [Class]
      def [](type)
        adapters[normalize type] || raise(Error, "Unknown MIME type: #{type}")
      end

      # Register a shortcut for MIME type
      #
      # @example
      #
      #   HTTP::MimeType.register_alias 'application/json', :json
      #
      # @param [#to_s] type
      # @param [#to_sym] shortcut
      # @return [void]
      def register_alias(type, shortcut)
        aliases[shortcut.to_sym] = type.to_s
      end

      # Resolves type by shortcut if possible
      #
      # @param [#to_s] type
      # @return [String]
      def normalize(type)
        aliases.fetch type, type.to_s
      end

      private

      # :nodoc:
      def adapters
        @adapters ||= {}
      end

      # :nodoc:
      def aliases
        @aliases ||= {}
      end
    end
  end
end

# built-in mime types
require "http/mime_type/json"
