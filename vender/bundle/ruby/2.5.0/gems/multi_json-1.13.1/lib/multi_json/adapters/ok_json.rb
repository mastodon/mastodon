require 'multi_json/adapter'
require 'multi_json/convertible_hash_keys'
require 'multi_json/vendor/okjson'

module MultiJson
  module Adapters
    class OkJson < Adapter
      include ConvertibleHashKeys
      ParseError = ::MultiJson::OkJson::Error

      def load(string, options = {})
        result = ::MultiJson::OkJson.decode("[#{string}]").first
        options[:symbolize_keys] ? symbolize_keys(result) : result
      rescue ArgumentError # invalid byte sequence in UTF-8
        raise ParseError
      end

      def dump(object, _ = {})
        ::MultiJson::OkJson.valenc(stringify_keys(object))
      end
    end
  end
end
