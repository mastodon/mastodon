# frozen_string_literal: true

require "json"
require "http/mime_type/adapter"

module HTTP
  module MimeType
    # JSON encode/decode MIME type adapter
    class JSON < Adapter
      # Encodes object to JSON
      def encode(obj)
        return obj.to_json if obj.respond_to?(:to_json)
        ::JSON.dump obj
      end

      # Decodes JSON
      def decode(str)
        ::JSON.parse str
      end
    end

    register_adapter "application/json", JSON
    register_alias   "application/json", :json
  end
end
