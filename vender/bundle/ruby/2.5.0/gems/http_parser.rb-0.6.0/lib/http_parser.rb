$:.unshift File.expand_path('../', __FILE__)
require 'ruby_http_parser'

Http = HTTP

module HTTP
  class Parser
    class << self
      attr_reader :default_header_value_type

      def default_header_value_type=(val)
        if (val != :mixed && val != :strings && val != :arrays)
          raise ArgumentError, "Invalid header value type"
        end
        @default_header_value_type = val
      end
    end
  end
end

HTTP::Parser.default_header_value_type = :mixed
