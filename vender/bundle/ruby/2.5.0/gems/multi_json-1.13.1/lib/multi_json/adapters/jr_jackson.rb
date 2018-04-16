require 'jrjackson' unless defined?(::JrJackson)
require 'multi_json/adapter'

module MultiJson
  module Adapters
    # Use the jrjackson.rb library to dump/load.
    class JrJackson < Adapter
      ParseError = ::JrJackson::ParseError

      def load(string, options = {}) #:nodoc:
        ::JrJackson::Json.load(string, options)
      end

      if ::JrJackson::Json.method(:dump).arity == 1
        def dump(object, _)
          ::JrJackson::Json.dump(object)
        end
      else
        def dump(object, options = {})
          ::JrJackson::Json.dump(object, options)
        end
      end
    end
  end
end
