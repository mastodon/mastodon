require 'singleton'
require 'multi_json/options'

module MultiJson
  class Adapter
    extend Options
    include Singleton

    class << self
      def defaults(action, value)
        metaclass = class << self; self; end

        metaclass.instance_eval do
          define_method("default_#{action}_options") { value }
        end
      end

      def load(string, options = {})
        string = string.read if string.respond_to?(:read)
        fail self::ParseError if blank?(string)
        instance.load(string, cached_load_options(options))
      end

      def dump(object, options = {})
        instance.dump(object, cached_dump_options(options))
      end

    private

      def blank?(input)
        input.nil? || /\A\s*\z/ === input
      rescue ArgumentError # invalid byte sequence in UTF-8
        false
      end

      def cached_dump_options(options)
        OptionsCache.fetch(:dump, options) do
          dump_options(options).merge(MultiJson.dump_options(options)).merge!(options)
        end
      end

      def cached_load_options(options)
        OptionsCache.fetch(:load, options) do
          load_options(options).merge(MultiJson.load_options(options)).merge!(options)
        end
      end
    end
  end
end
