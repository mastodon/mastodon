require 'active_support/core_ext/array/extract_options'
module ActiveModelSerializers
  class SerializationContext
    class << self
      attr_writer :url_helpers, :default_url_options
      def url_helpers
        @url_helpers ||= Module.new
      end

      def default_url_options
        @default_url_options ||= {}
      end
    end
    module UrlHelpers
      def self.included(base)
        base.send(:include, SerializationContext.url_helpers)
      end

      def default_url_options
        SerializationContext.default_url_options
      end
    end

    attr_reader :request_url, :query_parameters, :key_transform

    def initialize(*args)
      options = args.extract_options!
      if args.size == 1
        request = args.pop
        options[:request_url] = request.original_url[/\A[^?]+/]
        options[:query_parameters] = request.query_parameters
      end
      @request_url = options.delete(:request_url)
      @query_parameters = options.delete(:query_parameters)
      @url_helpers = options.delete(:url_helpers) || self.class.url_helpers
      @default_url_options = options.delete(:default_url_options) || self.class.default_url_options
    end
  end
end
