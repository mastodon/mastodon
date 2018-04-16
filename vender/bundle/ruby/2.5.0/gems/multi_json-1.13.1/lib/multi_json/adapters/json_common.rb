require 'multi_json/adapter'

module MultiJson
  module Adapters
    class JsonCommon < Adapter
      defaults :load, :create_additions => false, :quirks_mode => true

      def load(string, options = {})
        if string.respond_to?(:force_encoding)
          string = string.dup.force_encoding(::Encoding::ASCII_8BIT)
        end

        options[:symbolize_names] = true if options.delete(:symbolize_keys)
        ::JSON.parse(string, options)
      end

      def dump(object, options = {})
        options.merge!(::JSON::PRETTY_STATE_PROTOTYPE.to_h) if options.delete(:pretty)
        object.to_json(options)
      end
    end
  end
end
