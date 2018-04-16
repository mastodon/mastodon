module Seahorse
  module Model
    class Operation

      def initialize
        @http_method = 'POST'
        @http_request_uri = '/'
        @deprecated = false
        @errors = []
        @metadata = {}
      end

      # @return [String, nil]
      attr_accessor :name

      # @return [String]
      attr_accessor :http_method

      # @return [String]
      attr_accessor :http_request_uri

      # @return [Boolean]
      attr_accessor :deprecated

      # @return [String, nil]
      attr_accessor :documentation

      # @return [String, nil]
      attr_accessor :authorizer

      # @return [ShapeRef, nil]
      attr_accessor :input

      # @return [ShapeRef, nil]
      attr_accessor :output

      # @return [Array<ShapeRef>]
      attr_accessor :errors

      # APIG only
      # @return [Boolean]
      attr_accessor :require_apikey

      def [](key)
        @metadata[key.to_s]
      end

      def []=(key, value)
        @metadata[key.to_s] = value
      end

    end
  end
end
