require 'set'
require 'oj'
require 'multi_json/adapter'

module MultiJson
  module Adapters
    # Use the Oj library to dump/load.
    class Oj < Adapter
      defaults :load, :mode => :strict, :symbolize_keys => false
      defaults :dump, :mode => :compat, :time_format => :ruby, :use_to_json => true

      # In certain cases OJ gem may throw JSON::ParserError exception instead
      # of its own class. Also, we can't expect ::JSON::ParserError and
      # ::Oj::ParseError to always be defined, since it's often not the case.
      # Because of this, we can't reference those classes directly and have to
      # do string comparison instead. This will not catch subclasses, but it
      # shouldn't be a problem since the library is not known to be using it
      # (at least for now).
      class ParseError < ::SyntaxError
        WRAPPED_CLASSES = %w[Oj::ParseError JSON::ParserError].to_set.freeze

        def self.===(exception)
          case exception
          when ::SyntaxError
            true
          else
            WRAPPED_CLASSES.include?(exception.class.to_s)
          end
        end
      end

      def load(string, options = {})
        options[:symbol_keys] = options[:symbolize_keys]
        ::Oj.load(string, options)
      end

      def dump(object, options = {})
        options.merge!(:indent => 2) if options[:pretty]
        options[:indent] = options[:indent].to_i if options[:indent]
        ::Oj.dump(object, options)
      end
    end
  end
end
