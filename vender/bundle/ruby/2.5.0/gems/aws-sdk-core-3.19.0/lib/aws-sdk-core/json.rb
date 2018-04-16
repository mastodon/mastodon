require 'json'
require_relative 'json/builder'
require_relative 'json/error_handler'
require_relative 'json/handler'
require_relative 'json/parser'

module Aws
  # @api private
  module Json

    class ParseError < StandardError

      def initialize(error)
        @error = error
        super(error.message)
      end

      attr_reader :error

    end

    class << self

      def load(json)
        ENGINE.load(json, *ENGINE_LOAD_OPTIONS)
      rescue ENGINE_ERROR => e
        raise ParseError.new(e)
      end

      def load_file(path)
        self.load(File.open(path, 'r', encoding: 'UTF-8') { |f| f.read })
      end

      def dump(value)
        ENGINE.dump(value, *ENGINE_DUMP_OPTIONS)
      end

      private

      def oj_engine
        require 'oj'
        [Oj, [{mode: :compat, symbol_keys: false}], [{ mode: :compat }], oj_parse_error]
      rescue LoadError
        false
      end

      def json_engine
        [JSON, [], [], JSON::ParserError]
      end

      def oj_parse_error
        if Oj.const_defined?('ParseError')
          Oj::ParseError
        else
          SyntaxError
        end
      end

    end

    # @api private
    ENGINE, ENGINE_LOAD_OPTIONS, ENGINE_DUMP_OPTIONS, ENGINE_ERROR =
      oj_engine || json_engine

  end
end
