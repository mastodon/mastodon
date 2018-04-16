require 'yajl'
require 'multi_json/adapter'

module MultiJson
  module Adapters
    # Use the Yajl-Ruby library to dump/load.
    class Yajl < Adapter
      ParseError = ::Yajl::ParseError

      def load(string, options = {})
        ::Yajl::Parser.new(:symbolize_keys => options[:symbolize_keys]).parse(string)
      end

      def dump(object, options = {})
        ::Yajl::Encoder.encode(object, options)
      end
    end
  end
end
